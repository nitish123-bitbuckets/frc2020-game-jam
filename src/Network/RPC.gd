# The RPC Singleton is a place to hold all of our remote functions
# called by clients to send messages or servers to notify clients of messages
#
# This class contains two types of functions, send_* functions to make RPC calls to clients or the server
# and the actual remote methods that are executed by the clients or servers in response to the send_* method
extends Node

# a few notes on RPCs
# remotesync - means "execute on all clients including me". This is used for calls that execute on the server and client
# remote - means "execute on all clients except me". This is used for the server to broadcast to clients
# remote with rpc_id(1, ...) means execute only on the server. The server has an id of 1

func send_server_day_updated(day):
	# Make an RPC to notify clients of a new day
	rpc("server_day_updated", day)

remotesync func server_day_updated(day):
	# The server calls this function and it executes on each clients
	# each client uses it to update it's current day
	# print_debug ("Client: a new day: %d" % day)

	Signals.emit_signal("day_passed", day)

func send_join_game(player_name: String) -> void:
	# tell the server we joined the game
	print("Sending player_joined call to server for %s" % player_name)
	rpc_id(1, "player_joined", player_name)

remotesync func player_joined(player_name: String) -> void:
	print("Received player_joined message for %s from %s" % [player_name, get_tree().get_rpc_sender_id()])
	Signals.emit_signal("player_joined", get_tree().get_rpc_sender_id(), player_name)

func send_players_info(id: int, players: Dictionary) -> void:
	# Anytime a new player connects, send them a dictionary of players
	rpc_id(id, "update_players", players)

remotesync func update_players(players: Dictionary) -> void:
	# when a new player connects, update our players dictionary
	Signals.emit_signal("update_connected_players", players)


func send_pre_start_game(players: Array):
	# notify clients we are all ready to start
	assert(get_tree().is_network_server())

	print("Server: Notifying clients to prepare to start")

	# Call to pre-start game for everyone to get setup
	rpc("pre_start_game", players)

remotesync func pre_start_game(players: Array):
	# Do any prep work to start the game, like create world, setup players, etc
	print("Client: Preparing to start game")
	Signals.emit_signal("pre_start_game", players)


func send_ready_to_start():
	print("Client: Sending ready_to_start to server")
	rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())


remotesync func ready_to_start(id):
	assert(get_tree().is_network_server())
	print("Server: Client %d is ready to start" % id)
	Signals.emit_signal("player_ready_to_start", id)

func send_post_start_game():
	# sent by the server when all players are ready and we have begun
	rpc("post_start_game")

remotesync func post_start_game():
	# this is called on both clients and servers after the game has started
	Signals.emit_signal("post_start_game")

func send_player_updated(player: PlayerData):
	# sent our updated player info to all servers
	rpc("player_updated", player.to_dict())

remote func player_updated(player: Dictionary):
	Signals.emit_signal("player_updated", player);
