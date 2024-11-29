extends AnimatedSprite2D

# Variáveis para controlar o movimento
var amplitude = 40.0  # Distância máxima que o sprite vai subir e descer
var velocidade = 3.5  # Velocidade do movimento
var pos_inicial = Vector2.ZERO  # Posição inicial do sprite
var tempo_pas = 0.0  # Acumulador de tempo

# Variáveis para controlar a animação
var anim_ativada = false  # Flag para garantir que a animação só será ativada uma vez

func _ready():
	# Salva a posição inicial do sprite
	pos_inicial = position

func _process(delta):
	# Atualiza o acumulador de tempo
	tempo_pas += delta
	# Calcula o movimento vertical usando uma função senoidal
	position.y = pos_inicial.y + sin(tempo_pas * velocidade) * amplitude
	
	# Verifica se a tecla Space foi pressionada
	
	if not get_parent().game_running:
			animation = "parado"
	else:
		animation = "atacando"  # Troque pelo nome da animação desejada
		anim_ativada = true  # Marca que a animação já foi ativada
