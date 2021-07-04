import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rgntrainer_frontend/my_routes.dart';
import 'package:rgntrainer_frontend/models/user_model.dart';
import 'package:rgntrainer_frontend/provider/admin_calls_provider.dart';
import 'package:rgntrainer_frontend/provider/auth_provider.dart';
import 'package:rgntrainer_frontend/provider/user_results_provider.dart';
import 'package:rgntrainer_frontend/screens/no_token_screen.dart';
import 'package:rgntrainer_frontend/utils/user_simple_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class AdminResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminResultsCard();
  }
}

class AdminResultsCard extends StatefulWidget {
  const AdminResultsCard({
    Key? key,
  }) : super(key: key);

  @override
  _AdminCardState createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminResultsCard> {
  late User _currentUser = User.init();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = UserSimplePreferences.getUser();
    _fetchTotalUserResults();
    print(_currentUser.token);
  }

  //Fetch all Listings
  Future _fetchTotalUserResults() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<UserResultsProvider>(context, listen: false)
        .getTotalUserResults(_currentUser.token);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    if (_currentUser.token == null || _currentUser.usertype != "admin") {
      return NoTokenScreen();
    } else if (_isLoading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      final _myUserResultsProvider = context.watch<UserResultsProvider>();
      return Scaffold(
        appBar: AppBar(
          title: Text("Begrüssungs- und Erreichbarkeitstrainer"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.list_alt),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.build_rounded),
              onPressed: () {
                context.vxNav.push(
                  Uri.parse(MyRoutes.adminRoute),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                context.vxNav.push(
                  Uri.parse(MyRoutes.adminProfilRoute),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                AuthProvider().logout(_currentUser.token);
                context.vxNav.push(
                  Uri.parse(MyRoutes.loginRoute),
                );
              },
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: Container(
          padding: const EdgeInsets.all(100.0),
          child: ListView(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "User Ansicht",
                  style: TextStyle(fontSize: 42),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Resultate für User: ${_currentUser.username}",
                  style: const TextStyle(fontSize: 34),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 2,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 5,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: userResultsData(_myUserResultsProvider),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget userResultsData(UserResultsProvider _myUserResultsProvider) {
    return DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text("Nummer"),
          ),
          DataColumn(
            label: Text("Abteilung"),
          ),
          DataColumn(
            label: Text("Datum"),
          ),
          DataColumn(
            label: Text("erreicht"),
          ),
          DataColumn(
            label: Text("Organisation gesagt"),
          ),
          DataColumn(
            label: Text("Abteilung gesagt"),
          ),
          DataColumn(
            label: Text("Büro gesagt"),
          ),
          DataColumn(
            label: Text("Vorname gesagt"),
          ),
          DataColumn(
            label: Text("Nachname gesagt"),
          ),
          DataColumn(
            label: Text("Begrüssung gesagt"),
          ),
          DataColumn(
            label: Text("Spezifische Wörter gesagt"),
          ),
          DataColumn(
            label: Text("Anrufbeantworter gestartet"),
          ),
          DataColumn(
            label: Text("Anrufbeantworter korrekt"),
          ),
          DataColumn(
            label: Text("Zurückgerufen (Falls AB)"),
          ),
          DataColumn(
            label: Text("Rückruf rechtzeitig (Falls AB)"),
          ),
          DataColumn(
            label: Text("Anruf abgeschlossen"),
          ),
        ],
        rows: _myUserResultsProvider.userResults
            .map((data) => DataRow(cells: [
                  DataCell(Text(data.number.toString())),
                  DataCell(Text(data.department.toString())),
                  DataCell(Text(data.date.toString())),
                  DataCell(getCheck(checked: data.reached)),
                  DataCell(getCheck(checked: data.saidOrganization)),
                  DataCell(getCheck(checked: data.saidDepartment)),
                  DataCell(getCheck(checked: data.saidBureau)),
                  DataCell(getCheck(checked: data.saidFirstname)),
                  DataCell(getCheck(checked: data.saidName)),
                  DataCell(getCheck(checked: data.saidGreeting)),
                  DataCell(getCheck(checked: data.saidSpecificWords)),
                  DataCell(getCheck(checked: data.responderStarted)),
                  DataCell(getCheck(checked: data.responderCorrect)),
                  DataCell(getCheck(checked: data.callbackDone)),
                  DataCell(getCheck(checked: data.callbackInTime)),
                  DataCell(getCheck(checked: data.callCompleted)),
                ]))
            .toList());
  }
}

Icon getCheck({bool? checked}) {
  if (checked == null) {
    return const Icon(Icons.minimize, color: Colors.grey, size: 24);
  }
  if (checked == true) {
    return const Icon(Icons.check, color: Colors.green, size: 24);
  } else {
    return const Icon(Icons.clear, color: Colors.red, size: 24);
  }
}