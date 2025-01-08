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
	var stomp := StateStompMultiple.new(self)
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


class StateStompMultiple extends AI.State:
	const StompAttackScene = preload("res://assets/entities/projectile/stomp_attack/stomp_attack.tscn")

	var stomp_count := 3


	func _init(init_mob: Mob3D) -> void:
		super("Stomp multiple times", init_mob)


	func enter() -> void:
		for i in range(stomp_count):
			mob.skin.play("attack")

			var stomp_attack := StompAttackScene.instantiate()
			mob.add_sibling(stomp_attack)
			stomp_attack.global_position = mob.global_position
			await mob.get_tree().create_timer(1.0).timeout

		mob.get_tree().create_timer(0.7).timeout.connect(func():
			finished.emit())
		finished.emit()
