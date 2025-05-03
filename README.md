This is an example project for the sake of debugging input prediction within a netfox addon environment.
Literally, its just a box that moves towards the mouse & scales speed with distance from the character.
Input prediction does not work. please help.

The basic networking structure:

1) Server detects peer connection (Network.gd), calls a spawn function on a MultiplayerSpawner to synchronize client object order across all peers
2) Network.gd sends a signal over to the Game world (Game.gd)
3) Game.gd then checks if you are the server (does nothing if not), waits 3 seconds, then spawns a character for the new client via a different MultiplayerSynchronizer.
4) the Character.gd object is my base class for all playable characters. the scene spawned is a Shrimp.gd character, with a Rollback Synchronizer

5) RollbackSynchronizer saves :global_transform and :velocity as the two state variables, and as the input there is only MousePos.

CharacterInput.gd, inheriting from BaseNetInput, is where the issue is arising.

No matter what lag i put the system under through my network limiter Clumsy.exe, CharacterInput.gd never has RollbackSynchronizer.is_predicting() EVER return true. I have never successfully had is_predicting() return true once in my entire time (5 days) using netfox, and I do not know what to do.

To run a server, two debug instances must be ran, but one of them must have the launch argument of --Server (capitalization matters)
