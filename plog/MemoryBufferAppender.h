#pragma once

#include <plog/Appenders/IAppender.h>
#include <plog/WinApi.h>
#include <vector>

namespace plog
{
    template<class Formatter, class Converter = UTF8Converter>
    class MemoryBufferAppender : public IAppender
    {
    public:
        MemoryBufferAppender(std::string& buffer ,size_t bufferReallocStepSize)
            : m_bufferReallocStepSize(bufferReallocStepSize)
            , m_firstWrite(true)
            , m_buffer(buffer)
        {
            if (m_buffer.capacity() < m_bufferReallocStepSize)
                m_buffer.reserve(m_bufferReallocStepSize);
        }

        virtual void write(const Record& record)
        {
            util::MutexLock lock(m_mutex);

            if (m_firstWrite)
            {
                initBuffer();
                m_firstWrite = false;
            }

            std::string str = Converter::convert(Formatter::format(record));
            if (str.size() + m_buffer.size() > m_buffer.capacity())
            {
                if (m_bufferReallocStepSize)
                {
                    m_buffer.reserve(m_buffer.capacity() + m_bufferReallocStepSize);
                    m_buffer.insert(m_buffer.end(), str.c_str(), str.c_str() + str.size());
                }
                else
                {
                }
            }
            else
            {
                m_buffer.insert(m_buffer.end(), str.c_str(), str.c_str() + str.size());
            }
        }

    private:
        void initBuffer()
        {
            std::string str = Converter::header(Formatter::header());
            m_buffer.insert(m_buffer.begin(), str.c_str(), str.c_str() + str.size());
            int a = 0;
        }

    protected:
        util::Mutex         m_mutex;
        std::string&        m_buffer;
        size_t              m_bufferReallocStepSize;
        bool                m_firstWrite;
    };
}
