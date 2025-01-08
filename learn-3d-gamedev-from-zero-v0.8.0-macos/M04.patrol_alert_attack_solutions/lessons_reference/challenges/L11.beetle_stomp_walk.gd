extends Mob3D


func _ready() -> void:
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)

	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)

	var idle := AI.StateIdle.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	var wait_before_stomp := AI.StateWait.new(self)
	wait_before_stomp.duration = 1.0
	var stomp := StateStompWalk.new(self)
	var wait_after_stomp := AI.StateWait.new(self)
	wait_after_stomp.duration = 1.5

	var stagger := AI.StateStagger.new(self)
	var die := AI.StateDie.new(self)

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
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
		stagger: {
			AI.Events.FINISHED: idle,
		},
	}

	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	state_machine.add_transition_to_all_states(AI.Events.PLAYER_DIED, idle)

	state_machine.activate(idle)
	state_machine.is_debugging = true


class StateStompWalk extends AI.State:
	const StompAttackScene = preload("res://assets/entities/projectile/stomp_attack/stomp_attack.tscn")

	var duration := 3.0
	var walk_speed := 2.0

	var _time := 0.0

	func _init(init_mob: Mob3D) -> void:
		super("Stomp walk", init_mob)


	func enter() -> void:
		_time = 0.0
		mob.skin.play("walk")
		mob.skin.stepped.connect(spawn_stomp_attack)


	func spawn_stomp_attack() -> void:
		var stomp_attack := StompAttackScene.instantiate()
		mob.add_sibling(stomp_attack)
		stomp_attack.global_position = mob.global_position


	func update(delta: float) -> Events:
		_time += delta
		mob.velocity = mob.global_basis.z * walk_speed
		mob.move_and_slide()
		if _time >= duration:
			return Events.FINISHED
		else:
			return Events.NONE


	func exit() -> void:
		mob.skin.stepped.disconnect(spawn_stomp_attack)
