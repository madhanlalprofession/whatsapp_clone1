import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedChat = -1;

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Whatsapp",
      home: Scaffold(
        appBar: buildAppBar(),
        drawer: buildDrawer(),
        body: screenWidth > 600 // Check if the screen width is larger than 600px
            ? Row(
          children: [
            Container(
              width: 300,
              color: Colors.grey[200],
              child: chatList(),
            ),
            scrollableVLine(),
            Expanded(
              child: Container(
                color: Colors.white,
                child: selectedChat == -1
                    ? Center(child: Text("Select a chat to start messaging", style: TextStyle(color: Colors.black54)))
                    : chatBox(),
              ),
            ),
          ],
        )
            : Column( // Use Column layout for smaller screens (Mobile Phones)
          children: [
            Container(
              height: 250,
              color: Colors.grey[200],
              child: chatList(),
            ),
            if (selectedChat != -1)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: chatBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff075e54),
      title: const Center(
        child: Text(
          "WhatsApp",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search term',
              ),
            );
          },
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            print("You selected more options");
          },
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF1F1F1),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 30,
            child: const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                  "https://i.postimg.cc/63LKr7nd/photo-of-madhan.jpg"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.contact_page),
            title: const Text("Contact"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget scrollableVLine() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        height: 1000,
        width: 2,
        color: Colors.grey,
      ),
    );
  }

  Widget chatList() {
    return ListView.builder(
      itemCount: chatData.length,
      itemBuilder: (context, index) {
        final chat = chatData[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['url']),
          ),
          title: Text(
            chat['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(chat['lastmsg']),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(chat['date']),
              Icon(
                chat['icon'],
                color: chat['icon'] == Icons.done_all ? Colors.blue : Colors.grey,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              selectedChat = index;
            });
          },
        );
      },
    );
  }

  Widget chatBox() {
    final chat = chatData[selectedChat];
    final messages = chat['messages'] ?? [];
    final TextEditingController _messageController = TextEditingController();

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(child: Text("No messages yet"))
              : ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMyMessage = message['sender'] == 'me';
              Icon? tickIcon;

              if (message['status'] == 'read' && isMyMessage) {
                tickIcon = const Icon(Icons.done_all, size: 14, color: Colors.blue);
              } else if (message['status'] == 'sent' && isMyMessage) {
                tickIcon = const Icon(Icons.done, size: 14, color: Colors.grey);
              } else if (message['status'] == 'delivered' && isMyMessage) {
                tickIcon = const Icon(Icons.done_all, size: 14, color: Colors.grey);
              }

              return Align(
                alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12.0), // Padding inside the message box
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Gap from edges
                  decoration: BoxDecoration(
                    color: isMyMessage ? Colors.green[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment:
                    isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0), // Padding between text and time
                        child: Text(
                          message['text'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message['time'] ?? '',
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                          if (tickIcon != null) ...[
                            const SizedBox(width: 4.0), // Spacing between time and tick icon
                            tickIcon,
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), // Padding around the text input field
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Padding for input text
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: const Color(0xff075e54)),
                onPressed: () {
                  final newMessage = {
                    'text': _messageController.text,
                    'time': 'Now',
                    'sender': 'me',
                    'status': 'sent',
                  };
                  setState(() {
                    if (selectedChat != -1 && _messageController.text.isNotEmpty) {
                      chat['messages'].add(newMessage);
                      _messageController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


  final List<Map<String, dynamic>> chatData = [
    {
      'url': 'https://i.postimg.cc/63LKr7nd/photo-of-madhan.jpg',
      'name': 'madhan',
      'lastmsg': 'ok then',
      'date': '01/02/2024',
      'icon': Icons.done,
      'messages': [
        {'text': 'Hello!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi!', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'How are you ?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'I am fine what about you', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'good,had your lunch', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah just now,what is the matter?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nothing can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok when do we go?', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'didnt decide yet will update you once decided', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you decided', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'ok then', 'time': '10:14 AM', 'sender': 'me', 'status': 'sent'},

      ],

    },
    {
      'url': 'https://i.postimg.cc/wBfQCjhD/modi.jpg',
      'name': 'modi',
      'lastmsg': 'hamara rain coat mey',
      'date': '22/08/2024',
      'icon': Icons.done_all,
      'messages': [
        {'text': 'namaskaram modi ji!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'good morning madhan what are you doing', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'just now i woke up ji,what about you?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'i am the PM of this country man I should wake up early', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'yeah ji can we go to the movie', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'what movie should we go?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'you are the PM ji you can decide', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'arey madhan dont be childish suggest a movie', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'then what about viduthalai 2 ji', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'viduthalai 2 bahut acha movie heyy', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'yeah ji is it okay', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'okay for me', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'hamara rain coat mey', 'time': '10:14 AM', 'sender': 'me', 'status': 'read'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/6qtL7vWD/singa.jpg',
      'name': 'durai singam',
      'lastmsg': ' ',
      'date': '22/08/2024',
      'icon': Icons.done_all,
      'messages': [
      ],
    },
    {
      'url': 'https://i.postimg.cc/nLg0sLCp/srk.jpg',
      'name': 'SRK',
      'lastmsg': 'i am the king',
      'date': '23/04/2024',
      'icon': Icons.done_all,
      'messages': [
        {'text': 'Hello! SRK', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi madhan how are you?', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'I am fine what about you sir', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'insha allah iam very fine', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nice to hear that', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'why did you message me?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'movie? i love movies which movie', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'yeah i know about that ,thats only i texted you', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you get ready', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'i am the king', 'time': '10:14 AM', 'sender': 'me', 'status': 'read'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/nzwZ9BqM/vijay.jpg',
      'name': 'vijay',
      'lastmsg': 'vanakanga na',
      'date': '23/12/2024',
      'icon': Icons.done,
      'messages': [
        {'text': 'anna vanakanga na', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'nanba vanakam nanba', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'epdi riukeenga nanba ', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': ' na nalla iruke nanba enna sudden message', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'summa tha anna katchi velaigal ellam epdi poguthu', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ellam sirapa pogutu nanba', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'anna nanum unga katchi la join panikava', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'enna nanba ipdi kekura kandippa join panikalam nanba', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'thanks anna', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'sari nanba na aprm nerla meet panren', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'sari anna aprm meet panalam', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'vanakam nanba', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'vanakanga na', 'time': '10:14 AM', 'sender': 'me', 'status': 'sent'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/RZVBdgGq/dhoni.jpg',
      'name': 'dhoni',
      'lastmsg': 'definitely not',
      'date': '28/12/2024',
      'icon': Icons.done_all,
      'messages': [
        {'text': 'Hello!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi!', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'How are you ?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'I am fine what about you', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'good,had your lunch', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah just now,what is the matter?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nothing can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok when do we go?', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'didnt decide yet will update you once decided', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you decided', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'definitely not', 'time': '10:14 AM', 'sender': 'me', 'status': 'read'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/7h9H9hGT/rajini.jpg',
      'name': 'rajini',
      'lastmsg': 'hey superstar da',
      'date': '19/11/2024',
      'icon': Icons.done,
      'messages': [
        {'text': 'Hello!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi!', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'How are you ?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'I am fine what about you', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'good,had your lunch', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah just now,what is the matter?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nothing can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok when do we go?', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'didnt decide yet will update you once decided', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you decided', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'hey superstar da', 'time': '10:14 AM', 'sender': 'me', 'status': 'sent'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/Y0hnnyjf/kamal.jpg',
      'name': 'kamal',
      'lastmsg': 'ungalil oruvan',
      'date': '11/08/2024',
      'icon': Icons.done_all,
      'messages': [
        {'text': 'Hello!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi!', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'How are you ?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'I am fine what about you', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'good,had your lunch', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah just now,what is the matter?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nothing can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok when do we go?', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'didnt decide yet will update you once decided', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you decided', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'ungalil oruvan', 'time': '10:14 AM', 'sender': 'me', 'status': 'read'},

      ],
    },
    {
      'url': 'https://i.postimg.cc/Y9VZHw5y/amitabh.jpg',
      'name': 'amitabh',
      'lastmsg': 'croreapthi ka corepathi',
      'date': '29/12/2024',
      'icon': Icons.done,
      'messages': [
        {'text': 'Hello!', 'time': '10:00 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'Hi!', 'time': '10:01 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'How are you ?', 'time': '10:05 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'I am fine what about you', 'time': '10:06 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'good,had your lunch', 'time': '10:06 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah just now,what is the matter?', 'time': '10:08 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'nothing can we go to a movie', 'time': '10:10 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok when do we go?', 'time': '10:11 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'didnt decide yet will update you once decided', 'time': '10:11 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'ok buddy reach me once you decided', 'time': '10:12 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'will you come surely', 'time': '10:13 AM', 'sender': 'me', 'status': 'read'},
        {'text': 'yeah man', 'time': '10:13 AM', 'sender': 'madhan', 'status': ''},
        {'text': 'croreapthi ka corepathi', 'time': '10:14 AM', 'sender': 'me', 'status': 'sent'},

      ],
    }
  ];
}