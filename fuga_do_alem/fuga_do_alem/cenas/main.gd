extends Node

#pré-carregamento de obstaculos
var pedra_cena = preload("res://cenas/pedra.tscn")
var lapide_cena = preload("res://cenas/lapide.tscn")
var morcego_cena = preload("res://cenas/morcego.tscn")
var tipo_obstaculos := [pedra_cena, lapide_cena]
var obstaculos : Array
var morcego_dimensoes := [200, 390]

#variaveis do jogo
const JOG_START_POS := Vector2i(420, 485)
const CAM_START_POS := Vector2i(576, 324)
const MORTE_START_POS := Vector2i(125, 300)
var dificuldade
const MAX_DIFICULDADE : int = 2
var pontuacao : int
const MOD_PONTUACAO : int = 10
var high_score : int
var velocidade : float
const VEL_INICIAL : float = 10.0
const VELOCIDADE_MAX : int = 25
const MOD_VELOCIDADE : int = 5000
var tamanho_tela : Vector2i
var chao_altura : int
var game_running : bool
var ultimo_obs

#chamado quando o nó entra na árvore de cena pela primeira vez.
func _ready():
	$musicaFundo.play()
	tamanho_tela = get_window().size
	chao_altura = $Chao.get_node("Chao").texture.get_height()
	$GameOver.get_node("Restart").pressed.connect(new_game)
	new_game()

func new_game():
	#reseta as variaveis
	pontuacao = 0
	show_score()
	game_running = false
	get_tree().paused = false
	dificuldade = 0
	
	#deleta todos os obstaculos
	for obs in obstaculos:
		obs.queue_free()
	obstaculos.clear()
	
	#reseta os nós
	$Jogador.position = JOG_START_POS
	$Jogador.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Chao.position = Vector2i(0, 0)
	$Morte.position = MORTE_START_POS
	$musicaFundo.stop()
	$musicaFundo.play()
	
	
	#reseta cena do HUD e GameOver
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

#chamado cada quadro. 'delta' é o tempo decorrido desde o quadro anterior.
func _process(delta):
	if game_running:
		#acelerar e ajustar a dificuldade
		velocidade = VEL_INICIAL + pontuacao / MOD_VELOCIDADE
		if velocidade > VELOCIDADE_MAX:
			velocidade = VELOCIDADE_MAX
		adjust_difficulty()
		
		#gera obstaculos
		generate_obs()
		
		#move jogador, camera e morte
		$Jogador.position.x += velocidade
		$Camera2D.position.x += velocidade
		$Morte.position.x += velocidade
		
		#atualiza pontuacao
		pontuacao += velocidade
		show_score()
		
		#atualiza posição do chão
		if $Camera2D.position.x - $Chao.position.x > tamanho_tela.x * 1.5:
			$Chao.position.x += tamanho_tela.x
			
		#remove obstaculos que sairam de cena
		for obs in obstaculos:
			if obs.position.x < ($Camera2D.position.x - tamanho_tela.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#gera obstaculos do chao
	if obstaculos.is_empty() or ultimo_obs.position.x < pontuacao + randi_range(300, 500):
		var obs_type = tipo_obstaculos[randi() % tipo_obstaculos.size()]
		var obs
		var max_obs = dificuldade + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = tamanho_tela.x + pontuacao + 100 + (i * 100)
			var obs_y : int = tamanho_tela.y - chao_altura - (obs_height * obs_scale.y / 1.2) + 5
			ultimo_obs = obs
			add_obs(obs, obs_x, obs_y)
		#chance adicional de gerar morcego
		if dificuldade == MAX_DIFICULDADE:
			if (randi() % 2) == 0:
				#gera obstaculo morcego
				obs = morcego_cena.instantiate()
				var obs_x : int = tamanho_tela.x + pontuacao + 100
				var obs_y : int = morcego_dimensoes[randi() % morcego_dimensoes.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstaculos.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstaculos.erase(obs)
	
func hit_obs(body):
	if body.name == "Jogador":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(pontuacao / MOD_PONTUACAO)

func check_high_score():
	if pontuacao > high_score:
		high_score = pontuacao
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / MOD_PONTUACAO)

func adjust_difficulty():
	dificuldade = pontuacao / MOD_PONTUACAO
	if dificuldade > MAX_DIFICULDADE:
		dificuldade = MAX_DIFICULDADE

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
