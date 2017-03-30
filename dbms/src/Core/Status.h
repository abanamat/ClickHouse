#pragma once

#include <string>
#include <unordered_set>
#include <unordered_map>

#include <Core/Types.h>

namespace DB
{

class ReadBuffer;
class WriteBuffer;

namespace Protocol
{

struct Status
{
    struct Request
    {
        std::unordered_set<std::string> tables;

        void write(WriteBuffer & out, UInt64 server_protocol_revision) const;
        void read(ReadBuffer & in, UInt64 client_protocol_revision);
    };

    struct Response
    {
        struct TableStatus
        {
            bool is_replicated;
            UInt32 absolute_delay;
            UInt32 relative_delay;

            void write(WriteBuffer & out, UInt64 client_protocol_revision) const;
            void read(ReadBuffer & in, UInt64 server_protocol_revision);
        };

        std::unordered_map<std::string, TableStatus> table_states_by_id;

        void write(WriteBuffer & out, UInt64 client_protocol_revision) const;
        void read(ReadBuffer & in, UInt64 server_protocol_revision);
    };
};

}

}
