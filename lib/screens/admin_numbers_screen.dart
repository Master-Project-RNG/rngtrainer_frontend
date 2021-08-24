import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rgntrainer_frontend/models/numbers_model.dart';
import 'package:rgntrainer_frontend/my_routes.dart';
import 'package:rgntrainer_frontend/models/user_model.dart';
import 'package:rgntrainer_frontend/provider/admin_numbers_provider.dart';
import 'package:rgntrainer_frontend/provider/auth_provider.dart';
import 'package:rgntrainer_frontend/provider/bureau_results_provider.dart';
import 'package:rgntrainer_frontend/screens/no_token_screen.dart';
import 'package:rgntrainer_frontend/utils/user_simple_preferences.dart';
import 'package:rgntrainer_frontend/widgets/add_number_dialog.dart';
import 'package:rgntrainer_frontend/widgets/error_dialog.dart';
import 'package:rgntrainer_frontend/widgets/text_dialog_widget.dart';
import 'package:rgntrainer_frontend/widgets/ui/calendar_widget.dart';
import 'package:rgntrainer_frontend/widgets/ui/navbar_widget.dart';
import 'package:rgntrainer_frontend/widgets/ui/title_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/date_symbol_data_local.dart';

class AdminNumbersScreen extends StatefulWidget {
  const AdminNumbersScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AdminNumbersState createState() => _AdminNumbersState();
}

class _AdminNumbersState extends State<AdminNumbersScreen> {
  late User _currentUser = User.init();
  var _isLoading = false;

  List<Number> _numbers = [];
  List<Number> _numberPerBureau = [];

  late List<String> _getBureausNames = [];
  String pickedBureau = '';
  int selectedQueryType = 0; //pickedBureau index for dropdownmenu

  @override
  void initState() {
    super.initState();
    _currentUser = UserSimplePreferences.getUser();
    _asyncData();
    // ignore: avoid_print
    print("CurrentUserToken: ${_currentUser.token!}");
    initializeDateFormatting(); //set CalendarWidget language to German
  }

  //Fetch all Listings
  Future _asyncData() async {
    setState(() {
      _isLoading = true;
    });
    _getBureausNames =
        await Provider.of<BureauResultsProvider>(context, listen: false)
            .getBureausNames(_currentUser.token);
    _getBureausNames.remove("Overall");
    pickedBureau = _getBureausNames[0];
    _numbers = await Provider.of<NumbersProvider>(context, listen: false)
        .getAllUsersNumbers(_currentUser.token);
    numberPerBureau();
    setState(() {
      _isLoading = false;
    });
  }

  //Update list of numbers (e.g. after creation of new number)
  Future _updateNumbers() async {
    setState(() {
      _isLoading = true;
    });
    _numbers = await Provider.of<NumbersProvider>(context, listen: false)
        .getAllUsersNumbers(_currentUser.token);
    numberPerBureau();
    setState(() {
      _isLoading = false;
    });
  }

  void numberPerBureau() {
    _numberPerBureau = [];
    // ignore: avoid_function_literals_in_foreach_calls
    _numbers.forEach((element) {
      if (element.bureau == pickedBureau) {
        _numberPerBureau.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser.token == null || _currentUser.usertype != "admin") {
      return NoTokenScreen();
    } else {
      return Row(
        children: [
          NavBarWidget(_currentUser),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 65,
                titleSpacing:
                    0, //So that the title start right away at the left side
                title: CalendarWidget(),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.vxNav.push(
                        Uri.parse(MyRoutes.adminProfilRoute),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      AuthProvider().logout(_currentUser.token!);
                      context.vxNav.clearAndPush(
                        Uri.parse(MyRoutes.loginRoute),
                      );
                    },
                  )
                ],
                automaticallyImplyLeading: false,
              ),
              body: Column(
                children: [
                  TitleWidget("Nummern"),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 50, top: 50, right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Nummern der Büros für ${_currentUser.username}",
                          style: const TextStyle(fontSize: 34),
                        ),
                        _isLoading
                            ? Container()
                            : SizedBox(
                                child: PopupMenuButton(
                                  onSelected: (result) {
                                    setState(() {
                                      selectedQueryType = result as int;
                                      pickedBureau = _getBureausNames[result];
                                      numberPerBureau();
                                    });
                                  },
                                  itemBuilder: (context) {
                                    return List.generate(
                                      _getBureausNames.length,
                                      (index) {
                                        return PopupMenuItem(
                                          value: index,
                                          child: Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerLeft,
                                                width: 240,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    _getBureausNames[index]
                                                        .toString(),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: DropdownButton(
                                      value: this.selectedQueryType,
                                      items: getDropdownMenuItemList(
                                          _getBureausNames),
                                    ),
                                  ),
                                ),
                              ),
                        InkWell(
                          onTap: () async {
                            bool isSuccessful = await addNumberDialog(context,
                                bureauNames: _getBureausNames);
                            if (isSuccessful) _updateNumbers();
                          },
                          child: SizedBox(
                            width: 200,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              alignment: Alignment.center,
                              child: const Text(
                                'Nummer hinzufügen',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                      child: ListView(
                        children: [
                          Container(
                            color: Colors.grey[200],
                            child: buildDataTable(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading == true)
                    Expanded(
                      flex: 80,
                      child: const SizedBox(
                        height: 60,
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  final columns = [
    "Nummer",
    "Büro",
    "Abteilung",
    "Vorname",
    "Nachname",
    "Email",
  ];

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      return DataColumn(label: Text(column));
    }).toList();
  }

  List<DataRow> getRows(List<Number> numbers) => numbers.map((Number number) {
        final cells = [
          number.number,
          number.bureau,
          number.department,
          number.firstname,
          number.lastname,
          number.email
        ];

        return DataRow(
          cells: modelBuilder(cells, (index, cell) {
            final showEditIcon =
                index == 2 || index == 3 || index == 4 || index == 5;
            return DataCell(
              Text('$cell'),
              showEditIcon: showEditIcon,
              onTap: () {
                switch (index) {
                  case 2:
                    editDepartment(number);
                    break;
                  case 3:
                    editFirstName(number);
                    break;
                  case 4:
                    editLastName(number);
                    break;
                  case 5:
                    editEmail(number);
                    break;
                }
              },
            );
          }),
        );
      }).toList();

  Future editDepartment(Number editUser) async {
    final department = await showTextDialog(
      context,
      title: 'Abteilung aktualisieren',
      value: editUser.department,
    );
    if (department != null) {
      try {
        await Provider.of<NumbersProvider>(context, listen: false).updateUser(
            token: _currentUser.token!,
            basepool_id: editUser.basepool_id,
            user_id: editUser.user_id,
            department: department, //To be changed!
            firstName: editUser.firstname,
            lastName: editUser.lastname,
            email: editUser.email,
            ctx: context);
        // update hole list
        _numbers = _numbers.map((user) {
          final isEditedUser = user == editUser;
          return isEditedUser ? user.copy(department: department) : user;
        }).toList();
        // apply to current selection
        setState(() => _numberPerBureau = _numberPerBureau.map((user) {
              final isEditedUser = user == editUser;
              return isEditedUser ? user.copy(department: department) : user;
            }).toList());
      } catch (error) {
        SelfMadeErrorDialog.showErrorDialog(
            message: "Die neue Abteilung konnte nicht abgespeichert werden!",
            context: context);
      }
    }
  }

  Future editFirstName(Number editUser) async {
    final firstName = await showTextDialog(
      context,
      title: 'Vorname aktualisieren',
      value: editUser.firstname,
    );
    if (firstName != null) {
      try {
        await Provider.of<NumbersProvider>(context, listen: false).updateUser(
            token: _currentUser.token!,
            basepool_id: editUser.basepool_id,
            user_id: editUser.user_id,
            department: editUser.department,
            firstName: firstName, //To be changed!
            lastName: editUser.lastname,
            email: editUser.email,
            ctx: context);
        // update hole list
        _numbers = _numbers.map((user) {
          final isEditedUser = user == editUser;
          return isEditedUser ? user.copy(firstname: firstName) : user;
        }).toList();
        // apply to current selection
        setState(() => _numberPerBureau = _numberPerBureau.map((user) {
              final isEditedUser = user == editUser;
              return isEditedUser ? user.copy(firstname: firstName) : user;
            }).toList());
      } catch (error) {
        SelfMadeErrorDialog.showErrorDialog(
            message: "Die neue Vorname konnte nicht abgespeichert werden!",
            context: context);
      }
    }
  }

  Future editLastName(Number editUser) async {
    final lastName = await showTextDialog(
      context,
      title: 'Nachname aktualisieren',
      value: editUser.lastname,
    );
    if (lastName != null) {
      try {
        await Provider.of<NumbersProvider>(context, listen: false).updateUser(
            token: _currentUser.token!,
            basepool_id: editUser.basepool_id,
            user_id: editUser.user_id,
            department: editUser.department,
            firstName: editUser.firstname,
            lastName: lastName, //To be changed!
            email: editUser.email,
            ctx: context);
        //update hole list
        _numbers = _numbers.map((user) {
          final isEditedUser = user == editUser;
          return isEditedUser ? user.copy(lastname: lastName) : user;
        }).toList();
        // Also apply to current selection
        setState(() => _numberPerBureau = _numberPerBureau.map((user) {
              final isEditedUser = user == editUser;
              return isEditedUser ? user.copy(lastname: lastName) : user;
            }).toList());
      } catch (error) {
        SelfMadeErrorDialog.showErrorDialog(
            message: "Der neue Nachname konnte nicht abgespeichert werden!",
            context: context);
      }
    }
  }

  Future editEmail(Number editUser) async {
    final eMail = await showTextDialog(
      context,
      title: 'Email aktualisieren',
      value: editUser.email,
    );
    if (eMail != null) {
      try {
        await Provider.of<NumbersProvider>(context, listen: false).updateUser(
            token: _currentUser.token!,
            basepool_id: editUser.basepool_id,
            user_id: editUser.user_id,
            department: editUser.department,
            firstName: editUser.firstname,
            lastName: editUser.lastname,
            email: eMail, //To be changed!
            ctx: context);
        //update hole list
        _numbers = _numbers.map((user) {
          final isEditedUser = user == editUser;
          return isEditedUser ? user.copy(email: eMail) : user;
        }).toList();
        // Also apply to current selection
        setState(() => _numberPerBureau = _numberPerBureau.map((user) {
              final isEditedUser = user == editUser;
              return isEditedUser ? user.copy(email: eMail) : user;
            }).toList());
      } catch (error) {
        SelfMadeErrorDialog.showErrorDialog(
            message: "Die neue Email konnte nicht abgespeichert werden!",
            context: context);
      }
    }
  }

  Widget buildDataTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
      dataRowHeight: 35,
      columns: getColumns(columns),
      rows: _isLoading ? [] : getRows(_numberPerBureau),
    );
  }

  static List<T> modelBuilder<M, T>(
          List<M> models, T Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, T>((index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();

  List<DropdownMenuItem> getDropdownMenuItemList(List<String> bureauNames) {
    List<DropdownMenuItem> result = [];
    for (int i = 0; i < bureauNames.length; i++) {
      result.add(
        DropdownMenuItem(
          child: Container(
            alignment: Alignment.centerLeft,
            width: 210,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _getBureausNames[i],
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          value: i,
        ),
      );
    }
    return result;
  }
}