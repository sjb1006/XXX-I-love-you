draw_self();

if (!variable_instance_exists(id, "__dnd_health"))
    __dnd_health = 0;

draw_healthbar(862, 48, 1536, 80, __dnd_health, c_white, 76, c_red, 0, true, true);
