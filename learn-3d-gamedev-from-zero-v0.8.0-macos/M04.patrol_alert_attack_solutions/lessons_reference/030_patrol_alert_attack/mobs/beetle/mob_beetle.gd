#ANCHOR:extends
class_name MobBeetle3D extends Mob3D
#END:extends


#ANCHOR:func_ready_definition
func _ready() -> void:
	#END:func_ready_definition
	#ANCHOR:state_machine
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)
	#END:state_machine

	#ANCHOR:hurt_box_took_hit
	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)
	#END:hurt_box_took_hit

	#ANCHOR:states_idle_chase
	var idle := AI.StateIdle.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	#END:states_idle_chase
	#ANCHOR:states_stomp
	var wait_before_stomp := AI.StateWait.new(self)
	wait_before_stomp.duration = 1.0
	var stomp := AI.StateStomp.new(self)
	var wait_after_stomp := AI.StateWait.new(self)
	wait_after_stomp.duration = 1.5
	#END:states_stomp

	#ANCHOR:states_stagger_die
	var stagger := AI.StateStagger.new(self)
	var die := AI.StateDie.new(self)
	#END:states_stagger_die

	#ANCHOR:transitions_01
	state_machine.transitions = {
		#END:transitions_01
		#ANCHOR:transitions_02
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		#END:transitions_02
		#ANCHOR:transitions_05
			AI.Events.PLAYER_ENTERED_ATTACK_RANGE: wait_before_stomp,
		},
		wait_before_stomp: {
			AI.Events.FINISHED: stomp,
		},
		stomp: {
			AI.Events.FINISHED: wait_after_stomp,
		},
		wait_after_stomp: {
			AI.Events.FINISHED: chase,
		},
		#END:transitions_05
		#ANCHOR:transitions_03
		stagger: {
			AI.Events.FINISHED: idle,
		},
		#END:transitions_03
	}

	#ANCHOR:transitions_04
	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	state_machine.add_transition_to_all_states(AI.Events.PLAYER_DIED, idle)
	#END:transitions_04

	#ANCHOR:activate
	state_machine.activate(idle)
	state_machine.is_debugging = true
	#END:activate
