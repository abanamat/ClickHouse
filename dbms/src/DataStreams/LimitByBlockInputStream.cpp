#include <DB/DataStreams/LimitByBlockInputStream.h>

namespace DB
{

LimitByBlockInputStream::LimitByBlockInputStream(BlockInputStreamPtr input_, size_t value_, Names columns_)
	: columns_names(columns_)
	, value(value_)
{
	children.push_back(input_);
}

String LimitByBlockInputStream::getID() const
{
	std::stringstream res;
	res << "LimitBy(" << children.back()->getID() << ")";
	return res.str();
}

Block LimitByBlockInputStream::readImpl()
{
	while (true)
	{
		Block block = children[0]->read();
		if (!block)
			return Block();

		const ConstColumnPlainPtrs column_ptrs(getKeyColumns(block));
		const size_t rows = block.rows();
		const size_t old_set_size = set.size();
		IColumn::Filter filter(rows);

		for (size_t i = 0; i < rows; ++i)
		{
			UInt128 key;
			SipHash hash;

			for (size_t j = 0; j < column_ptrs.size(); ++j)
				column_ptrs[j]->updateHashWithValue(i, hash);

			hash.get128(key.first, key.second);

			MapHashed::iterator si = set.find(key);
			if (si == set.end())
				si = set.insert(MapHashed::value_type(key, 0)).first;

			if (si->second < value)
			{
				si->second++;
				filter[i] = 1;
			}
			else
			{
				filter[i] = 0;
			}
		}

		if (set.size() == old_set_size)
			continue;

		size_t all_columns = block.columns();
		for (size_t i = 0; i < all_columns; ++i)
			block.getByPosition(i).column = block.getByPosition(i).column->filter(filter, -1);

		return block;
	}
}

ConstColumnPlainPtrs LimitByBlockInputStream::getKeyColumns(Block & block) const
{
	ConstColumnPlainPtrs column_ptrs;
	column_ptrs.reserve(columns_names.size());

	for (const auto & name : columns_names)
	{
		auto & column = block.getByName(name).column;

		/// Ignore all constant columns.
		if (!column->isConst())
			column_ptrs.emplace_back(column.get());
	}

	return column_ptrs;
}

}