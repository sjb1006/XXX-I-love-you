a = instance_create_layer(x, y, "Above_player", objzt);
a.direction = irandom(360);
a.speed = 5;
audio_play_sound(sndShoot, 0, 0, 0.1);
alarm[1] = 3.5;
