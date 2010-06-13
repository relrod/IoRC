SGML

Weather := Object clone do (
    query := method(location,
        xml := URL with("http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=#{location}" interpolate) fetch asXML
        self setSlot("current_observation", xml elementsWithName("current_observation") at(0))
        return
    )

    findSeq := method(tagname,
        seq := self current_observation elementsWithName(tagname) at(0) asString
        seq betweenSeq("<#{tagname}>" interpolate, "</#{tagname}>" interpolate)
    )
    
    observation_time := method( findSeq("observation_time") )
    location := method( findSeq("full") )
    conditions := method( findSeq("weather") )
    temperature_seq := method( findSeq("temperature_string") )
    humidity := method( findSeq("relative_humidity") )
    wind_seq := method( findSeq("wind_string") )
    
    currcond_seq := method(
        if(self conditions == "", return "An error occured, or, more likely, the location given was not found.")
        return "Currently in #{location} (#{observation_time}): Conditions are: #{conditions}. It is #{temperature_seq}. Humidity is #{humidity}. Wind is #{wind_seq}" interpolate
    )

)