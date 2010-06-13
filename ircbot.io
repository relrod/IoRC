#!/usr/bin/env io
// This is a test bot, written in Io, and for now, bound to not be decent.

// Core addons. Note that Regex in steve's branch is currently broken. --6/11/10
Regex // We're parsing with regex.
SGML // For misc. web stuff.

// Command Libraries
Importer addSearchPath("cmdlibs")
Morse // My morse library.
Weather // My weather library.

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
                //("[RX]"..(socket readBuffer)) println
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
            regex := "^:(.+)!(.+)@(\.+?) (\.+?) (\.+?) :(.+)$" asRegex
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
            
            if(message text beginsWithSeq("."),
                args := message text split(" ")
                command := args removeFirst removeAt(0);
                argsList := list(args join(" "))
                if(Commands hasLocalSlot(command),
                    response := Commands performWithArgList(command, argsList)
                    if(response != nil, message reply(response, true)),
                    message reply("Sorry, the #{command} command was not found." interpolate)
                )
            )

            return // We have to get back to the mainloop, so we can clear the buffer.
        )
    )
    
    Commands := Object clone do (
        
        help := method(commandname,
            //return self hasLocalSlot(commandname)
            if(self hasLocalSlot(commandname),
                return self performWithArgList(commandname, list("help")),
                return "Sorry, the #{commandname} command was not found." interpolate
            )
        )
        
        ping := method(args,
            help := "This method 'pong's to test the bot."
            if(args == "help", return help)
            return "Pong @ #{Date now}" interpolate
        )
        
        echo := method(args,
            help := "Echos <argument> to the user."
            if(args == "help", return help)
            return args
        )
        
        countlinks := method(args,
            sitesource := URL with(args) fetch
            linkscount := sitesource asXML elementsWithName("a") map(attributes at("href")) size
            return "#{args} contains #{linkscount} links" interpolate
        )
        
        minify := method(args,
            shorturl := URL with ("http://is.gd/api.php?longurl=#{args}" interpolate) fetch
            return shorturl 
        )
        
        weather := method(args,
            weather := Weather clone
            weather query(args)
            weather currcond_seq
        )
        
        raw := method(args,
            help := "Sends <quote> to the IRC server, followed by \\r\\n"
            if(args == "help", return help)
            Bot send(args)
            return nil
        )
        
    )
    
    
)

// You know what would really be nice? CONCURENCY! >.<
freenode := Bot clone
freenode identify("irc.freenode.net",6667,"IoIRC", list("##botkiteers"))
freenode mainloop


//slashnet := Bot clone
//slashnet identify("irc.slashnet.org",6667,"IoIRC", list("##botkiteers"))
//coroDo(freenode mainloop)
//slashnet mainloop