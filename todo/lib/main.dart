import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();
  // Função para adicionar itemss
  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(
        Item(
          title: newTaskCtrl.text,
          done: false,
        ),
      );
      newTaskCtrl.text = "";
      save();
    });
  }

  // função remove o item
  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

/*função para ler os itens assincrona,não é em tempo real e sim promessa,
  future funciona como promessa, algo que vem depois, vai ler as informaçoes
  assim que tiver algo retorna.
 */
  Future load() async {
    // Não irei prosseguir enquando o SharedPreference não estiver carregado.
    var prefs = await SharedPreferences.getInstance();
    //trabalha com chave e valor, salvando no formato json.
    var data = prefs.getString('data');
    if (data != null) {
      // pode-se fazer iteração dos itens, percorrer ela, lista genérica
      Iterable decoded = jsonDecode(data);
      // forech e convert os item para a lista.
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      //atualiza os itens da lista
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    /*
    Transforma a lista de itens em um json 
    Chave e Valor 
     */
    await prefs.setString('data', jsonEncode(widget.items));
  }

// toda a vez que a aplicação iniciar vai chamar o shared preferences.
  _HomePageState() {
    load();
  }
  @override
  Widget build(BuildContext context) {
    // sempre usa scaffold em uma página (esqueleto da página)
    return Scaffold(
      appBar: AppBar(
        // cria uma caixa de texto
        title: TextFormField(
          // controlador que obtém a informação do textbox
          controller: newTaskCtrl,
          //propriedade que exibe o teclado completo
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          // propriedade de decoração para o tetformfield
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          // constante que não pode ser alterada
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                // trocar o estado da tela
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        //chama a função add criada
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
