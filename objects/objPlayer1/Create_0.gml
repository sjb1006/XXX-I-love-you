frozen = false; //Sets if the player can move or not
global.grav=1
jump = 8.5 * global.grav; //Set how fast the player jumps
jump2 = 7 * global.grav; //Sets how fast the player double jumps
gravity = 0.4 * global.grav; //Player gravity

maxDjump = 1; //How many double jumps the player gets - 0 = single jump only, 1 = double jump, 2 = triple jump, etc.
djump = maxDjump; //Allow the player to double jump as soon as they spawn
runSpeed = 3;   //Max horizontal speed
maxVspeed = 9;  //Max vertical speed
image_speed = 0.2;
onPlatform = false;

xScale = 1;

if (global.grav == 1) {
	mask_index = sprPlayerMask;
} else {
	mask_index = sprPlayerMaskFlip;
}

if (global.difficulty == 0 && global.gameStarted)
    { instance_create_depth(x,y,depth-1,objBow); }
    
if (global.autosave) //Save the game if currently set to autosave
{
    scrSaveGame(true);
    global.autosave = false;
}

xsafe = x;
ysafe = y;

do_dynamic_collision(true);

