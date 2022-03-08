#include <plog/Log.h>
#include <plog/Init.h>
#include <plog/Formatters/TxtFormatter.h>
#include <plog/Formatters/FuncMessageFormatter.h>
#include <plog/Formatters/MessageOnlyFormatter.h>
#include <plog/Formatters/CsvFormatter.h>
#include <plog/Appenders/ColorConsoleAppender.h>
#include <plog/Appenders/ConsoleAppender.h>
#include <plog/Appenders/DebugOutputAppender.h>
#include <plog/Appenders/RollingFileAppender.h>
#include "MemoryBufferAppender.h"

/*
https://www.humio.com/glossary/logging-levels/

The Most Common Types of Logging Levels

Generally speaking, the logging framework is organized by the following logging levels, which are listed below in descending order of urgency or importance:

    Fatal: This log level indicates that at least one system component is inoperable which is causing a fatal error within the larger system.

    Error: This log entry notes that at least one system component is inoperable and is interfering with the operability of other functionalities.

    Warn: This log message indicates that an unexpected event has occurred in an application that may disrupt or delay other processes.

    Info: This log level captures an event that has occurred, though it does not appear to affect operations. These alerts usually can be ignored, assuming the rest of the system continues to operate normally.

    Debug: The debug log captures relevant detail of events that may be useful during software debugging or troubleshooting within the test environment.

    Verbose/Trace: This log level captures the execution of code. It is considered an info message and does not require action. That said, it may prove useful when the team needs full visibility within the application or a third-party library.

Some systems also rely on one of the following catch-all categories, which may serve as a default log level:

    All: All activity and events are added to the logger.

    Off: No activity or events are added to the logger.
*/

int main()
{
    std::string buffer;
    static plog::ColorConsoleAppender<plog::TxtFormatter> consoleAppender;
    plog::init(plog::verbose, &consoleAppender);

    for(int i = 0; i < 5; ++i)
    {

        // Log severity levels are printed in different colors.
        PLOG_NONE << "This is a NONE message = " << i;
        PLOG_VERBOSE << "This is a VERBOSE message";
        PLOG_DEBUG << "This is a DEBUG message";
        PLOG_INFO << "This is an INFO message ";
        PLOG_WARNING << "This is a WARNING message";
        PLOG_ERROR << "This is an ERROR message";
        PLOG_FATAL << "This is a FATAL message";
    }

    std::cout << buffer;

    std::cout << std::endl;

    return 0;
}