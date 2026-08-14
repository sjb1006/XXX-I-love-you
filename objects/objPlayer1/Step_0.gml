/// @description Player actions and movement

//Left-right input
var L = (scrButtonCheck(global.leftButton) || (scrButtonCheckPressed(global.leftButton)));
var R = (scrButtonCheck(global.rightButton) || (scrButtonCheckPressed(global.rightButton)));
var h = 0;
if (!frozen)
    { h = -(L || R) + (2 * R); }

var ice = instance_place(x, y + global.grav, objSlipBlock);
var notOnBlock = place_free(x, y + global.grav);
var onVineL = (place_meeting(x - 1, y, objWalljumpL) && notOnBlock);
var onVineR = (place_meeting(x + 1, y, objWalljumpR) && notOnBlock);

//Horizontal movement
if (h != 0)    //Moving
{
    xScale = h;
    if ((h == -1 && !onVineR) || (h == 1 && !onVineL))
    {
        if (ice == noone)    //Normal movement
            { hspeed = runSpeed * h; }
        else    //Ice movement
        {
            hspeed += (ice.slip) * h;
            
            if (abs(hspeed) > runSpeed)
                hspeed = runSpeed * h;
        }
    }
}
else    //Not moving
{
    if (ice == noone)    //Normal movement
        hspeed = 0;
    else    //Ice movement
    {
        if (hspeed > 0)
            { hspeed -= min(ice.slip, abs(hspeed)); }
        else if (hspeed < 0)
            { hspeed += min(ice.slip, abs(hspeed)); }
    }
}

// Check if standing on a platform
if (!onPlatform) {
    if ((vspeed * global.grav) < -0.05) {
		sprite_index = sprPlayerJump;
    } else if ((vspeed * global.grav) > 0.05) {
		sprite_index = sprPlayerFall;
	}
} else {
    if (!place_meeting(x,y+(4*global.grav),objPlatform)) {
		onPlatform = false;
	}
}


var slide = instance_place(x,y + (global.grav), objSlideBlock);
if (slide != noone)
{
    hspeed += slide.slide;
}

if (global.grav * vspeed > maxVspeed)
{
    vspeed = global.grav * maxVspeed;
}

// Check buttons for player actions
if (!frozen) { // Check if frozen before doing anything
    if (scrButtonCheckPressed(global.jumpButton)) {
        scrPlayerJump();
	}
    if (scrButtonCheckReleased(global.jumpButton)) {
        scrPlayerVJump();
	}
    if (scrButtonCheckPressed(global.shootButton)) {
        scrPlayerShoot();
	}
    if (scrButtonCheckPressed(global.suicideButton)) {
        scrKillPlayer();
	}
}

if (global.adAlign && !place_free(x, y + (global.grav)) && !frozen)
{
    if (scrButtonCheckPressed(global.alignLeftButton)) {hspeed -= 1;}
    if (scrButtonCheckPressed(global.alignRightButton)) {hspeed += 1;}
}


///Vines                                            

if (onVineL || onVineR)
{
    if (onVineR)
        { xScale = -1; }
    else
        { xScale = 1; }
    
    vspeed = 2 * global.grav;
    
    //Try to leave vine
    if (onVineL && scrButtonCheckPressed(global.rightButton)) || (onVineR && scrButtonCheckPressed(global.leftButton))
    {
        if (scrButtonCheck(global.jumpButton))    //Jumping off
        {
            if (onVineR)
                { hspeed = -15; }
            else
                { hspeed = 15; }
            vspeed = -9 * global.grav;
            audio_play_sound(sndWallJump, 0, false);
        }
        else    //Falling off
        {
            if (onVineR)
                { hspeed = -3; }
            else
                { hspeed = 3; }
        }
    }
}


///Slopes         

if (instance_exists(objSlope) && hspeed != 0)
{
    var moveLimit = abs(hspeed);    //Sets how high/low the player can go to snap onto a slope, this can be increased to make the player able to run over steeper slopes (ie setting it to abs(hspeed)*2 allows the player to run over slopes twice as steep)
    
    var slopeCheck;
    var hTest;
    
    var ySlope;
    
    //falling onto a slope
    if (place_meeting(x+hspeed, y+vspeed+gravity, objSlope) && (vspeed+gravity)*global.grav > 0 && notOnBlock)
    {
        var xLast = x;
        var yLast = y;
        var hLast = hspeed;
        var vLast = vspeed;
        
        vspeed += gravity;
        
        x += hspeed;
        hspeed = 0;
        
        if(!place_free(x, y+vspeed))
        {
            if (global.grav == 1)    //Normal
                move_contact_solid(270, abs(vspeed));
            else    //Flipped
                move_contact_solid(90, abs(vspeed));
            vspeed = 0;
        }
        
        y += vspeed;            
        
        if (!place_free(x, y + global.grav) && place_free(x, y))  //Snapped onto the slope properly
        {
            djump = maxDjump;
            notOnBlock = false;
        }
        else    //Did not snap onto the slope, return to previous position
        {
            x = xLast;
            y = yLast;
            hspeed = hLast;
            vspeed = vLast;
        }
    }
    
    //Moving down a slope
    if (!notOnBlock)
    {                                              
        var onSlope = (place_meeting(x, y + global.grav, objSlope));    //Treat normal blocks the same as slopes if we're standing on a slope
        
        slopeCheck = true;
        hTest = hspeed;
        
        while (slopeCheck)
        {
            ySlope = 0;
            //Check how far we should move down
            while ((!place_meeting(x + hTest, y - ySlope + global.grav, objSlope) || (onSlope && place_free(x + hTest, y - ySlope + global.grav))) && (ySlope*global.grav > -floor(moveLimit * (hTest/hspeed))))
            {
                ySlope -= global.grav;
            }
            
            //Check if we actually need to move down
            if (place_meeting(x + hTest, y - ySlope + global.grav, objSlope) || (onSlope && place_free(x + hTest, y - ySlope + global.grav)))
            {
                if (ySlope != 0 && place_free(x + hTest, y - ySlope))
                {
                    y -= ySlope;
                    
                    x += hTest;
                    hspeed = 0;
                    
                    slopeCheck = false;
                }
                else
                {
                    if (hTest > 0)
                    {
                        hTest -= 1;
                        if (hTest <= 0)
                            slopeCheck = false;
                    }
                    else if (hTest < 0)
                    {
                        hTest += 1;
                        if (hTest >= 0)
                            slopeCheck = false;
                    }
                    else
                    {
                        slopeCheck = false;
                    }
                }
            }
            else
            {
                slopeCheck = false;
            }
        }
    }
    
    //Moving up a slope
    if (place_meeting(x + hspeed, y, objSlope))
    {                                           
        slopeCheck = true;
        hTest = hspeed;
        
        while (slopeCheck)
        {
            ySlope = 0;
            
            //Check how far we have to move up
            while ( place_meeting(x + hTest, y - ySlope, objSlope) && (ySlope*global.grav < floor(moveLimit * (hTest/hspeed))) )
            {
                ySlope += global.grav;
            }                                                 
            
            //Check if we actually need to move up
            if (place_free(x + hTest, y - ySlope))
            {            
                y -= ySlope;
                
                x += hTest;
                hspeed = 0;
                
                slopeCheck = false;
            }
            else
            {
                if (hTest > 0)
                {
                    hTest -= 1;
                    if (hTest <= 0)
                        slopeCheck = false;
                }
                else if (hTest < 0)
                {
                    hTest += 1;
                    if (hTest >= 0)
                        slopeCheck = false;
                }
                else
                {
                    slopeCheck = false;
                }
            }
        }
    }
    
    //Set xprevious/yprevious coordinates for future solid collisions
    xprevious = x;
    yprevious = y;
}                 

///Block collision (Keep this last)

vspeed += gravity;

if (!place_free(x + hspeed, y + vspeed))
{
    if (!place_free(x + hspeed, y) && hspeed != 0)
    {
        var maxDist = abs(hspeed);
        var dir = 180 * (hspeed < 0);
        move_contact_solid(dir, maxDist);
        
        hspeed = 0;
    }
     
    if (!place_free(x, y + vspeed) && vspeed != 0)
    {
        var maxDist = abs(vspeed);
        var dir = 270 - 180 * (vspeed < 0);
        move_contact_solid(dir, maxDist);
        
        if (dir == 180 + global.grav * 90) {
            djump = maxDjump;
        }
        vspeed = 0;
    }
    
    if (!place_free(x + hspeed, y + vspeed))
    {
        //hspeed = 0;
        //Traditional behavior when resolving corner collision is to stop hspeed. When on a platform, this can cause horizontal stutter, so we stop vspeed instead.
        var p = instance_place(x, y+vspeed, objPlatform);
        if (!p || place_meeting(x, y, p))
        {
            hspeed = 0;
        }
        else
        {
            vspeed = 0;
        }
    }
}

xsafe = x + hspeed;
ysafe = y + vspeed;

vspeed -= gravity;

