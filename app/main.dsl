// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
// Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.  
    input phone: string;
    output new_time: string="";
    output new_day: string="";
    output number_of_people: string="";
    output hotel_stars: string="";
    output check_in_date: string="";
    output check_in_month: string="";
    output check_out_date: string="";
    output check_out_month: string="";
    output city: string="";
    output state: string="";
    output free: string="";
    output proximity: string="";  
// Storage variables. You'll be referring to them across the code. 
    date: string="";
    month: string="";
    number_value: string="";
}

// A start node that always has to be written out. Here we declare actions to be performed in the node. 
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the user's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the user say something
        #sayText("Hi, my name is Dasha, I'm here to assist you with finding and booking a hotel room. First, could you tell me which city and state you're traveling to, please?"); // Welcome message
        wait *; // Wating for the user to reply
    }
    transitions // Here you give directions to which nodes the conversation will go
    {
        hotel_stars: goto hotel_stars on #messageHasData("city") and #messageHasData("state"); // Get transferred to this node if the user mentions both city and state
        which_city: goto which_city on #messageHasData("state"); // Get transferred to this node if the user only mentions the state
        which_state: goto which_state on #messageHasData("city"); // Get transferred to this node if the user only mentions the city
    }
     onexit
    {
        hotel_stars: do {
        set $city = #messageGetData("city")[0]?.value??""; // Store city and state variables to use them later in the conversation
        set $state = #messageGetData("state")[0]?.value??"";
        }
        which_city: do {
        set $state = #messageGetData("state")[0]?.value??"";
        }
        which_state: do {
        set $city = #messageGetData("city")[0]?.value??"";
        }
    }
}

node which_city
{
    do
    {
        #sayText("And which city in " + $state + " are you going to?"); // $state comes from context 
        wait *;
    }
    transitions
    {
        hotel_stars: goto hotel_stars on #messageHasData("city");
    }
    onexit
    {
        hotel_stars: do {
        set $city = #messageGetData("city")[0]?.value??"";
        }
    }
}

node which_state
{
    do
    {
        #sayText("Sorry, could you specify the state for me, please?");
        wait *;
    }
    transitions
    {
        hotel_stars: goto hotel_stars on #messageHasData("state");
    }
    onexit
    {
        hotel_stars: do {
        set $state = #messageGetData("state")[0]?.value??"";
        }
    }
}

node hotel_stars
{
    do
    {
        #sayText("That's nice! " + $city + " is a grate place to visit! Ummm... How many stars would you want the hotel to have?");
        wait *;
    }
    transitions
    {
        how_many_people: goto how_many_people on #messageHasData("number_value", {tag: "stars"}) or #messageHasData("number_value");
    }
    onexit
    {
        how_many_people: do {
        set $hotel_stars = #messageGetData("number_value", {tag: "stars"})[0]?.value??"";
        }
    }
}


node how_many_people
{
    do
    {
        #sayText("Fantastic, I got that! " + $hotel_stars + " it is! Now, could you tell me how many people you said should the hotel room accommodate?");
        wait *;
    }
    transitions
    {
        confirm_guests: goto confirm_guests on #messageHasData("number_value", {tag: "people"}) or #messageHasData("number_value"); 
    }
    onexit
    {
        confirm_guests: do {
        set $number_of_people = #messageGetData("number_value", {tag: "people"})[0]?.value??"";
        }
    }
}

node confirm_guests
{
    do 
    { 
        #sayText("You said " + $number_of_people + ", is that right?");
        wait *;
    }
    transitions
    {
        check_in_date: goto check_in_date on #messageHasIntent("yes");
        repeat_guests: goto repeat_guests on #messageHasIntent("no");
    }
}

node repeat_guests
{
    do 
    {
        #sayText("Let's do it one more time. How many people you said should the hotel room accommodate?");
        wait *;
    }
    transitions 
    {
       confirm_guests: goto confirm_guests on #messageHasData("number_value", {tag: "date"});
    }
    onexit
    {
        confirm_guests: do {
        set $number_of_people = #messageGetData("number_value", {tag: "people"})[0]?.value??"";
        }
    }
}

node check_in_date
{
    do
    {
        #sayText("Just a couple more questions so I could ensure I pick the best place for you so please bear with me. Could you give me a date of your check in?");
        wait *;
    }
    transitions 
    {
       confirm_check_in: goto confirm_check_in on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_check_in: do {
        set $check_in_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $check_in_month  = #messageGetData("month")[0]?.value??"";
        }
    }
}


node confirm_check_in
{
    do 
    { 
        #sayText("Alrighty, I'm setting the check in date to " + $check_in_month + " " + $check_in_date + " , did I get that rigth?");
        wait *;
    }
    transitions
    {
        check_out_date: goto check_out_date on #messageHasIntent("yes");
        repeat_check_in: goto repeat_check_in on #messageHasIntent("no");
    }
}

node repeat_check_in
{
    do 
    {
        #sayText("Let's try again. When would you like to check in to the hotel?");
        wait *;
    }
    transitions 
    {
       confirm_check_in: goto confirm_check_in on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_check_in: do {
        set $check_in_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $check_in_month = #messageGetData("month")[0]?.value??"";
        }
    }
}

node check_out_date
{
    do
    {
        #sayText("Now, could you tell me when the check out date should be?");
        wait *;
    }
    transitions 
    {
       confirm_check_out: goto confirm_check_out on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_check_out: do {
        set $check_out_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $check_out_month  = #messageGetData("month")[0]?.value??"";
        }
    }
}


node confirm_check_out
{
    do 
    { 
        #sayText("Awesome, so just to make sure, the check out date is " + $check_out_month + " " + $check_out_date + " , am I rigth?");
        wait *;
    }
    transitions
    {
        proximity: goto proximity on #messageHasIntent("yes");
        repeat_check_out: goto repeat_check_out on #messageHasIntent("no");
    }
}

node repeat_check_out
{
    do 
    {
        #sayText("Let's do this again. When should I set the check out date to?");
        wait *;
    }
    transitions 
    {
       confirm_check_out: goto confirm_check_out on #messageHasData("number_value", {tag: "date"}) and #messageHasData("month");
    }
    onexit
    {
        confirm_check_out: do {
        set $check_out_date = #messageGetData("number_value", {tag: "date"})[0]?.value??"";
        set $check_out_month = #messageGetData("month")[0]?.value??"";
        }
    }
}

node proximity
{
    do 
    {
        #sayText("At this point I'd like to ask how close would you like the hotel to be to the center of the city?");
        wait *;
    }
    transitions 
    {
       proximity_confirm: goto proximity_confirm on #messageHasData("proximity");
    }
    onexit
    {
       proximity_confirm: do {
        set $proximity = #messageGetData("proximity")[0]?.value??"";
       }
    }
}

node proximity_confirm
{
    do 
    {   
        if ($proximity == "close to the center"){
            #sayText("Close to the center, got that. That's probably the nicest area to be in! Now, would you require free parkign or free Wi-Fi to be present at the hotel?");
        }
        else {
            #sayText("Farther from the center, got that. I've heard the nature in the outskirts of " + $city + " is fascinating! Now, would you require free parkign or free Wi-Fi to be present at the hotel?");
        }
        wait *;
    }
    transitions 
    {
       free_confirm: goto free_confirm on #messageHasData("free");
    }
    onexit
    {
       free_confirm: do {
       set $free = #messageGetData("free")[0]?.value??""; 
       }
    }
}

node free_confirm
{
    do 
    {   
        if ($free == "free parking"){
            #sayText("Sounds like a plan, I'll look for a hotel that has free parking. Let's figure out the pricing you're comfortable with. Would you like the hotel to be in the low, below 50 dollars, medium, that's between 50 and 150 dollars, or high price range, which is above 150 dollars?");
        }
        else if ($free == "free parking and wi-fi"){
            #sayText("Sounds like a plan, I'll look for a hotel that has both free Wi-Fi and parking. Let's figure out the pricing you're comfortable with. Would you like the hotel to be in the low, below 50 dollars, medium, that's between 50 and 150 dollars, or high price range, which is above 150 dollars?");
        }
        else {
            #sayText("Sounds like a plan, I'll look for a hotel that has free Wi-Fi. Let's figure out the pricing you're comfortable with. Would you like the hotel to be in the low, below 50 dollars, medium, that's between 50 and 150 dollars, or high price range, which is above 150 dollars?");
        }
        wait *;
    }
    transitions 
    {
        hotel_low_price: goto hotel_low_price on #messageHasIntent("hotel_low_price");
        hotel_high_price: goto hotel_high_price on #messageHasIntent("hotel_high_price");
        hotel_medium_price: goto hotel_medium_price on #messageHasIntent("hotel_medium_price");
        cost_doesnt_matter: goto cost_doesnt_matter on #messageHasIntent("cost_doesnt_matter");
    }
}

node hotel_low_price
{
    do 
    {
        #sayText("To review your requirements, you want to find a low price range hotel in " + $city + " , the room would be for " + $number_of_people + ", the hotel will have " + $hotel_stars + " stars, the check-in date would be " + $check_in_month + " " + $check_in_date + ", and the check-out date would be" + $check_out_month + " " + $check_out_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_low_price: goto search_low_price on #messageHasIntent("yes");
    }
}

node hotel_high_price
{
    do 
    {
        #sayText("To review your requirements, you want to find a high price range hotel in " + $city + " , the room would be for " + $number_of_people + ", the hotel will have " + $hotel_stars + " stars, the check-in date would be " + $check_in_month + " " + $check_in_date + ", and the check-out date would be" + $check_out_month + " " + $check_out_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_high_price: goto search_high_price on #messageHasIntent("yes");
    }
}

node hotel_medium_price
{
    do 
    {
        #sayText("To review your requirements, you want to find a medium price range hotel in " + $city + " , the room would be for " + $number_of_people + ", the hotel will have " + $hotel_stars + " stars, the check-in date would be " + $check_in_month + " " + $check_in_date + ", and the check-out date would be" + $check_out_month + " " + $check_out_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_medium_price: goto search_medium_price on #messageHasIntent("yes");
    }
}

node cost_doesnt_matter
{
    do 
    {
        #sayText("To review your requirements, you want to find a hotel in " + $city + " , the room would be for " + $number_of_people + ", the hotel will have " + $hotel_stars + ", the check-in date would be " + $check_in_month + " " + $check_in_date + ", and the check-out date would be" + $check_out_month + " " + $check_out_date + ". Is that right?");
        wait *;
    }
    transitions 
    {
        search_hotel: goto search_hotel on #messageHasIntent("yes");
    }
}

node search_low_price
{
    do 
    {
        #sayText("Awesome, I found two hotels that perfectly match your requirements. The first one is Butterfly Resort Hotel and the second one is Great Valley Inn. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        butterfly: goto butterfly on #messageHasIntent("butterfly");
        valley: goto valley on #messageHasIntent("valley");
    }
}

node butterfly
{
    do 
    {
        #sayText("This hotel costs 25 dollars per night. Would you like to book this one or hear more about the Great Valley Inn?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        valley: goto valley on #messageHasIntent("valley");
    }
}

node valley
{
    do 
    {
        #sayText("This hotel costs 30 dollars per night and it serves free continental breakfasts. Would you like to book this one or hear more about the Butterfly Resort Hotel?");
        wait *;
    }
    transitions 
    {
        butterfly: goto butterfly on #messageHasIntent("butterfly");
        book: goto book on #messageHasIntent("book");
    }
}

node search_medium_price
{
    do 
    {
        #sayText("Awesome, I found two hotels that perfectly match your requirements. The first one is Hello Hotel and the second one is Sunflower Inn. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        hello_hotel: goto hello_hotel on #messageHasIntent("hello_hotel");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
    }
}

node hello_hotel
{
    do 
    {
        #sayText("This hotel costs 88 dollars per night. It provides free continental breakfasts. Would you like to book this one or hear more about the Sunflower Inn?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
    }
}

node sunflower
{
    do 
    {
        #sayText("This hotel costs 66 dollars per night and it serves free continental breakfasts and has flexible check out time. Would you like to book this one or hear more about the Hello Hotel?");
        wait *;
    }
    transitions 
    {
        hello_hotel: goto hello_hotel on #messageHasIntent("hello_hotel");
        book: goto book on #messageHasIntent("book");
    }
}

node search_high_price
{
    do 
    {
        #sayText("Awesome, I found two hotels that perfectly match your requirements. The first one is Dandelion Hotel and the second one is Rose Petal Inn. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        rose: goto rose on #messageHasIntent("rose");
    }
}

node dandelion
{
    do 
    {
        #sayText("This hotel costs 217 dollars per night. It provides free continental breakfasts, has flexible check out time, and a free outside and inside pools. Would you like to book this one or hear more about the Rose Petal Inn?");
        wait *;
    }
    transitions 
    {
        book: goto book on #messageHasIntent("book");
        rose: goto rose on #messageHasIntent("rose");
    }
}

node rose
{
    do 
    {
        #sayText("This hotel costs 311 dollars per night and it serves free continental breakfasts and has free lunch, it has flexible check out time and a free SPA. Would you like to book this one or hear more about the Dandelion Hotel?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        book: goto book on #messageHasIntent("book");
    }
}

node search_hotel
{
    do 
    {
        #sayText("Awesome, I found four hotels that perfectly match your requirements. The first one is Dandelion Hotel, the second is Rose Petal Inn, the third one is Sunflower Inn and the last one is Great Valley Inn. Which one would you like more about?");
        wait *;
    }
    transitions 
    {
        dandelion: goto dandelion on #messageHasIntent("dandelion");
        rose: goto rose on #messageHasIntent("rose");
        sunflower: goto sunflower on #messageHasIntent("sunflower");
        valley: goto valley on #messageHasIntent("valley");
    }
}

node book
{
    do 
    {
        #sayText("Perfect, the room at the hotel has been booked! It was a pleasure helping you find the right hotel. I'll send the booking confirmation and other information in a text message. Have a fantastic rest of the day. Bye!");
        exit;
    }
}