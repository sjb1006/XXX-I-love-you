if (wudi == 0)
{
    wudi = 1;
    image_alpha = 0.7;
    __dnd_health -= 5;
    alarm[0] = 70;
    audio_play_sound(sndBossHit, 0, 0);
}
instance_destroy(other)
