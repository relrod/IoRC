Morse := Map clone do (
    /* Todo: Add more punct. etc. But this is more for proof of concept.*/
    atPut("a", ".-");       atPut("b","-...");
    atPut("c","-.-.");      atPut("d","-..");
    atPut("e",".");         atPut("f","..-.");
    atPut("g","--.");       atPut("h","....");
    atPut("i","..");        atPut("j",".---");
    atPut("k","-.-");       atPut("l",".-..");
    atPut("m","--");        atPut("n","-.");
    atPut("o","---");       atPut("p",".--.");
    atPut("q","--.-");      atPut("r",".-.");
    atPut("s","...");       atPut("t","-");
    atPut("u","..-");       atPut("v","...-");
    atPut("w",".--");       atPut("y","-.--");
    atPut("z","--..");      atPut("1",".----");
    atPut("2","..---");     atPut("3","...--");
    atPut("4","....-");     atPut("5",".....");
    atPut("6","-....");     atPut("7","--...");
    atPut("8","---..");     atPut("9","----.");
    atPut("0","-----");     atPut(".",".-.-.");
    atPut("-","-...-");     atPut(",","--..--");
)

DeMorse := Morse reverseMap

morse := method(chars,
    output := "";
    chars foreach(i, v,
        letter := v asCharacter asLowercase;
        if(letter == " ", output = output .. " // ",  output = output .. Morse at(letter) .. " ")
    );
    return output
)

demorse := method(chars,
    output := "";
    letters := chars split(" ");
    letters foreach(letter,
        if(letter == "", output = output .. " ", output = output .. DeMorse at(letter))
    )
    return output
)