import 'package:flutter/material.dart';
import 'package:frosthaven_assistant/Model/monster.dart';

import '../../Resource/commands/add_monster_command.dart';
import '../../Resource/game_methods.dart';
import '../../Resource/game_state.dart';
import '../../services/service_locator.dart';

class AddMonsterMenu extends StatefulWidget {
  const AddMonsterMenu({Key? key}) : super(key: key);

  @override
  _AddMonsterMenuState createState() => _AddMonsterMenuState();
}

class _AddMonsterMenuState extends State<AddMonsterMenu> {
  // This list holds the data for the list view
  List<MonsterModel> _foundMonsters = [];
  final GameState _gameState = getIt<GameState>();

  @override
  initState() {
    // at the beginning, all users are shown
    _foundMonsters = _gameState.modelData.value!.monsters;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<MonsterModel> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _gameState.modelData.value!.monsters;
    } else {
      results = _gameState.modelData.value!.monsters
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundMonsters = results;
    });
  }

  bool _monsterAlreadyAdded(String id) {
    var monsters = GameMethods.getCurrentMonsters();
    for (var monster in monsters) {
      if (monster.id == id) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        //color: Colors.transparent,
        // shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(20),
        child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                      labelText: 'Add Monster', suffixIcon: Icon(Icons.search)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundMonsters.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundMonsters.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: Image(
                            height: 30,
                            image: AssetImage(
                                "assets/images/monsters/${_foundMonsters[index].gfx}.png"),
                          ),
                          //iconColor: _foundMonsters[index].color,
                          title: Text(
                              _foundMonsters[index].hidden
                                  ? "${_foundMonsters[index].display} (special)"
                                  : _foundMonsters[index].display,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: _monsterAlreadyAdded(
                                          _foundMonsters[index].name)
                                      ? Colors.grey
                                      : Colors.black)),
                          trailing: Text("(${_foundMonsters[index].edition})",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          onTap: () {
                            //TODO: add level selection menu  (0-7) on top in this here menu.
                            if (!_monsterAlreadyAdded(
                                _foundMonsters[index].name)) {
                              setState(() {
                                _gameState.action(AddMonsterCommand(
                                    _foundMonsters[index].name, null)); //
                              });

                              //Navigator.pop(context);
                            }
                          },
                        ),
                      )
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
              ),
            ],
          ),
          Positioned(
              width: 100,
              right: 2,
              bottom: 2,
              child: TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }))
        ]));
  }
}