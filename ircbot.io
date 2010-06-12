#!/usr/bin/env io
// This is a test bot, written in Io, and for now, bound to not be decent.

// Core addons. Note that Regex in steve's branch is currently broken. --6/11/10
Regex // We're parsing with regex.

// Command Libraries
Importer addSearchPath("cmdlibs")
Morse // My morse library.

Bot := Object clone do (
    socket := Socket clone
    
    send := method(content,
        socket streamWrite(content .. "\r\n")
        ("[TX] " .. content) println
    )
    
    setNick := method(nick,
        send("NICK #{nick}" interpolate)
    )
    
    joinChannel := method(channel,
        send("JOIN #{channel}" interpolate)
    )
    
    identify := method(server, port, nick, channels,
        socket setReadTimeout(60*60*24)
        socket setHost(server) setPort(port) connect
        setNick(nick)
        send("USER a a a a")
        channels foreach(channel,
            joinChannel(channel)
        )
        socket streamReadNextChunk
        socket readBuffer empty
    )
    
    mainloop := method(
        while(socket isOpen,
            socket streamReadNextChunk
            if(socket readBuffer size != 0,
                // Send it to the parser
                parse(socket readBuffer)
                socket readBuffer empty
            )
        )
    )
    
    parse := method(line,
        // Handle PING's first off.
        if(line beginsWithSeq("PING"),
            send("PONG " .. line split(" ") at(1) strip)
            return // Done with the function.
        )
        try(
            regex := "^:(.+)!(.+)@(.+) (.+) (.+) :(.+)" asRegex
            message := line matchesOfRegex(regex) next captures do (
                sender := Object clone
                sender nick := at(1)
                sender name := at(2)
                sender cloak := at(3)
            
                text := at(6) asMutable strip // So we don't have to do this manually.
                channel := at(5)
                type := at(4)
            
                reply := method(response, prependnick,
                    if(prependnick,
                        response := "#{sender nick}: #{response}" interpolate
                    )
                    Bot send("PRIVMSG #{channel} :#{response}" interpolate)
                )
                
                replyAction := method(response,
                    Bot send("PRIVMSG #{channel} :#{001 asCharacter}ACTION #{response}#{001 asCharacter}" interpolate)
                )
            )
        
            if(message text beginsWithSeq(".echo"),
                message reply(message text removeSlice(0,5), true)
            )
            
            if(message text beginsWithSeq(".npecho"),
                message reply(message text removeSlice(0,7), false)
            )
            
            if(message text beginsWithSeq(".act"),
                message replyAction(message text removeSlice(0,4))
            )
            
            if(message text beginsWithSeq(".morse"),
                message reply(morse(message text removeSlice(0,6)), true)
            )
            
            if(message text beginsWithSeq(".demorse"),
                message reply(demorse(message text removeSlice(0,8)), true)
            )
            
            return // We have to get back to the mainloop, so we can clear the buffer.
            
        )
    )
    
)

freenode := Bot clone
freenode identify("irc.freenode.net",6667,"IoIRC", list("##botkiteers"))
freenode mainloop