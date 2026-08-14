/// @description Resolve collisions between step and now, collide with dynamic blocks

if (!place_free(x, y))
{
    var dirX = sign(x-xsafe);
    var dirY = sign(y-ysafe);
    var epsilon = 0.001; //Appease the floating point gods
    
    //If something moved the player into a block since Step, move back towards where we were until we're out of a block.
    while(!place_free(x, y))
    {
        if (dirX * (x - xsafe) >= epsilon)
        {
            x -= sign(x-xsafe) * min( abs(x-xsafe), 1 );
        }
        else if (dirY * (y - ysafe) >= epsilon)
        {
            y -= sign(y-ysafe) * min( abs(y-ysafe), 1 );
        }
        else break;
    }
}

if (global.blocksCrush)
{
    do_dynamic_collision(false, scrKillPlayer);
}
else
{
    do_dynamic_collision(false);
}

// Check killer collision
if (place_meeting(x,y,objPlayerKiller)) {
	scrKillPlayer();
}

// Check water collision
with (objWaterParent) {
	event_user(0);
}

// Check save collision
with (objSave) {
	event_user(1);
}

// Check room changer collision
with (objRoomChanger) {
	event_user(0);
}

// Check warp next collision
with (objWarpNext) {
	event_user(0);
}

///Screen border death, player animation

if ((bbox_right < 0 || bbox_left > room_width || bbox_bottom < 0 || bbox_top > room_height) && global.edgeDeath)
{
    scrKillPlayer()
}


var notOnBlock = (place_free(x, y + global.grav));
var onVineR = (place_meeting(x + 1, y, objWalljumpR) && notOnBlock);
var onVineL = (place_meeting(x - 1, y, objWalljumpL) && notOnBlock);

if (!onVineR && !onVineL)   //Not touching any vines
{
    if (onPlatform || !notOnBlock)  //Standing on something
    {
        //Check if moving left/right
        var L = (scrButtonCheck(global.leftButton) || (scrButtonCheckPressed(global.leftButton)));
        var R = (scrButtonCheck(global.rightButton) || (scrButtonCheckPressed(global.rightButton)));
        
        if ((L || R) && !frozen)
        {
            sprite_index = sprPlayerRun;
            image_speed = 1/2;
        }
        else
        {
            sprite_index = sprPlayerIdle;
            image_speed = 1/5;
        }
    }
    else    //In the air
    { 
        if ((vspeed * global.grav) < 0)
        {
            sprite_index = sprPlayerJump;
            image_speed = 1/2;
        }
        else
        {
            sprite_index = sprPlayerFall;
            image_speed = 1/2;
        }
    }
}
else    //Touching a vine
{
    sprite_index = sprPlayerSlide;
    image_speed = 1/2;
}

with (objPlatform) {
	with (other) {
		if (place_meeting(x,y,other)) {
			if (global.grav == 1) { // Check if on top of the platform (when right-side up)
			    if (y-vspeed/2 <= other.y) {
			        if (other.vspeed >= 0) {
			            y = other.y-9; // Snap to the platform
			            vspeed = other.vspeed;
			        }
        
			        onPlatform = true;
			        djump = 1;
			    }
			} else { // Check if on top of the platform (when flipped)
			    if (y-vspeed/2 >= other.y+other.sprite_height-1) {
			        if (other.yspeed <= 0) {
			            y = other.y+other.sprite_height+8; // Snap to the platform
			            vspeed = other.yspeed;
			        }
        
			        onPlatform = true;
			        djump = 1;
			    }
			}
		}
	}
}

