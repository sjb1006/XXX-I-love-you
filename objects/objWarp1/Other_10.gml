/// @description Warp the player

if (place_meeting(x,y,objPlayer)) {
	if (warpX == 0 && warpY == 0) { // No coordinates set, go to where objPlayerStart is
	    with(objPlayer) {
	        instance_destroy();
		}
	} else { // Coordinates set, move player to them
	    objPlayer.x = warpX;
	    objPlayer.y = warpY;
	}
	with objPlayer{
		frozen = true;
	}
	instance_create_layer(0,0,"World",objBlack)
	room_goto(roomTo);

}