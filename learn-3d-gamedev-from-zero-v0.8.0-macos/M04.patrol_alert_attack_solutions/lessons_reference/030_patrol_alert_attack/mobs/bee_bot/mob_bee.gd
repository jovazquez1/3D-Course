#ANCHOR:class_definition
class_name MobBee3D extends Mob3D
#END:class_definition


#ANCHOR: func_ready_definition
func _ready() -> void:
#END: func_ready_definition
	#ANCHOR: add_state_machine
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)
	#END: add_state_machine

	#ANCHOR: states_idle_chase
	var idle := AI.StateIdle.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	#END: states_idle_chase
	#ANCHOR: states_look_at_player_charge_wait
	var look_at_player := AI.StateLookAtPlayer.new(self)
	look_at_player.duration = 2.0

	var charge := AI.StateCharge.new(self)
	charge.charge_speed = 14.0

	var wait_after_charge := AI.StateWait.new(self)
	wait_after_charge.duration = 1.5
	#END: states_look_at_player_charge_wait

	#ANCHOR: states_stagger
	var stagger := AI.StateStagger.new(self)
	#END: states_stagger
	#ANCHOR: states_die
	var die := AI.StateDie.new(self)
	#END: states_die

	#ANCHOR: transitions_01
	state_machine.transitions = {
	#END: transitions_01
		#ANCHOR: transitions_02_idle_to_chase
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
		#END: transitions_02_idle_to_chase
		},
		#ANCHOR: transitions_04_chase
		#ANCHOR: transitions_03_chase_to_idle
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		#END: transitions_03_chase_to_idle
		#ANCHOR: transitions_04_attack_sequence
			AI.Events.PLAYER_ENTERED_ATTACK_RANGE: look_at_player,
		},
		look_at_player: {
			AI.Events.FINISHED: charge,
		},
		charge: {
			AI.Events.FINISHED: wait_after_charge,
		},
		wait_after_charge: {
			AI.Events.FINISHED: chase,
		#END: transitions_04_attack_sequence
		},
		#END: transitions_04_chase
		#ANCHOR: transitions_05_stagger_01
		stagger: {
			AI.Events.FINISHED: idle,
		},
		#END: transitions_05_stagger_01
	}

	#ANCHOR: transitions_05_stagger_02
	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	#END: transitions_05_stagger_02
	#ANCHOR: transitions_06_die
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	#END: transitions_06_die
	#ANCHOR: transitions_07_player_died
	#state_machine.add_transition_to_all_states(AI.Events.PLAYER_DIED, idle)
	#END: transitions_07_player_died

	#ANCHOR: activate_idle
	state_machine.activate(idle)
	#END: activate_idle
	#ANCHOR: is_debugging
	state_machine.is_debugging = true
	#END: is_debugging

	#ANCHOR:ready_connect_hurt_box
	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)
	#END:ready_connect_hurt_box
