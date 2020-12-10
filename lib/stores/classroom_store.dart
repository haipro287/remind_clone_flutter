import "package:flutter/foundation.dart";
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:remind_clone_flutter/data/network/socket_service.dart';
import 'package:remind_clone_flutter/models/classroom/conversation.dart';
import "../models/classroom.dart";
import "package:remind_clone_flutter/data/network/api/classroom_api.dart";
import "package:remind_clone_flutter/data/network/rest_client.dart";

class ClassroomStore with ChangeNotifier {
  List<Classroom> classrooms = [];
  Classroom currentClassroom;
  final SocketService socketService = Injector().get<SocketService>();

  var _client = RestClient();

  ClassroomStore() {
    this.socketService.socket.on("NEW_MESSAGE", (dynamic msg) {
      int conversationId = msg["conversationId"];
      var conversation = getConversationById(conversationId);
      if (conversation == null || conversation.messages == null) {
        return;
      }
      var newMessage = Message.fromJson(msg);
      newMessage.setConversation(conversation);
      addMessage(conversation, newMessage);
    });

    this.socketService.socket.on("FIRST_NEW_MESSAGE", (dynamic data) {
      int classroomId = data["newConvo"]["classroom_id"];
      var newConvo = Conversation.fromJson(data["newConvo"]);
      var newMessage = Message.fromJson(data["newMsg"]);
      newConvo.setMessages([newMessage]);

      var classroom = getClassroomById(classroomId);

      if (classroom == null || classroom.conversations == null) return;
      classroom.addConversation(newConvo);
    });
  }

  Conversation getConversationById(int conversationId) {
    for (var classroom in classrooms) {
      if (classroom.conversations == null) {
        continue;
      }
      for (var convo in classroom.conversations) {
        if (convo.id == conversationId) {
          return convo;
        }
      }
    }

    return null;
  }

  void addClassroom(Classroom newClassroom) {
    this.classrooms.add(newClassroom);
    notifyListeners();
  }

  void setClassrooms(List<Classroom> classrooms) {
    this.classrooms = classrooms;
    notifyListeners();
  }

  Classroom getClassroomById(int id) {
    return this.classrooms.firstWhere((classroom) => classroom.id == id);
  }

  List<Classroom> getJoinedClassrooms() {
    return classrooms.where((classroom) => classroom.type == "Member").toList();
  }

  List<Classroom> getOwnedClassrooms() {
    return classrooms.where((classroom) => classroom.type == "Owner").toList();
  }

  Future<void> fetchUserClassrooms(String token) async {
    var classroomApi = ClassroomApi(_client);

    var classrooms = await classroomApi.getUserClassrooms(token);
    var classroomList = List<Classroom>();
    for (var classroom in classrooms) {
      classroomList.add(Classroom.fromJson(classroom));
    }
    setClassrooms(classroomList);
  }

  void resetClassrooms() {
    classrooms = [];
    currentClassroom = null;
  }

  Future<List<ClassroomFile>> fetchClassroomFiles(
    String token,
    int classroomId, {
    bool forced = false,
  }) async {
    var classroom = getClassroomById(classroomId);

    if (classroom.files.length > 0 && !forced) {
      // TODO: I can't tell if the files have been fetched before this way.
      return classroom.files;
    }

    var classroomApi = ClassroomApi(_client);
    var classroomFiles = await classroomApi.getClassroomFiles(
      token,
      classroomId.toString(),
    );

    List<ClassroomFile> newFiles = [];

    for (var file in classroomFiles) {
      newFiles.add(ClassroomFile.fromJson(file));
    }

    classroom.setFiles(newFiles);

    notifyListeners();

    return classroom.files;
  }

  Future<List<Conversation>> fetchConversations(
    String token,
    int classroomId, {
    bool forced = false,
  }) async {
    var classroom = getClassroomById(classroomId);
    if (classroom.conversations != null && !forced) {
      return classroom.conversations;
    }

    var classroomApi = ClassroomApi(_client);
    var conversations = await classroomApi.getConversations(
      token,
      classroomId.toString(),
    );

    List<Conversation> newConvos = [];

    for (var convo in conversations) {
      newConvos.add(Conversation.fromJson(convo));
    }

    classroom.setConversations(newConvos);

    return classroom.conversations;
  }

  Future<List<Message>> fetchMessages(
      String token, Conversation conversation) async {
    try {
      if (conversation.messages != null) {
        return conversation.messages;
      }

      var classroomApi = ClassroomApi(_client);
      var messages =
          await classroomApi.getMessages(token, conversation.id.toString());

      List<Message> newMessages = [];
      Message message;
      for (var messageObj in messages) {
        message = Message.fromJson(messageObj)..setConversation(conversation);
        newMessages.add(message);
      }

      conversation.setMessages(newMessages);
      notifyListeners();
      return conversation.messages;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  void addMessage(Conversation conversation, Message message) {
    conversation.addMessage(message);
    notifyListeners();
  }

  void setCurrentClassroom(int currentClassroomId) {
    currentClassroom =
        classrooms.firstWhere((element) => element.id == currentClassroomId);
    notifyListeners();
  }

  Classroom getCurrentClassroom() {
    return currentClassroom;
  }
}
