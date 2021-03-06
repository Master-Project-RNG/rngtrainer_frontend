import 'package:flutter/material.dart';
import 'package:rgntrainer_frontend/models/call_type.dart';
import 'package:rgntrainer_frontend/models/user_model.dart';
import 'package:rgntrainer_frontend/my_routes.dart';
import 'package:rgntrainer_frontend/provider/admin_calls_provider.dart';
import 'package:rgntrainer_frontend/provider/auth_provider.dart';
import 'package:rgntrainer_frontend/screens/components/line_chart_widget.dart';
import 'package:rgntrainer_frontend/screens/no_token_screen.dart';
import 'package:rgntrainer_frontend/utils/user_simple_preferences.dart';
import 'package:rgntrainer_frontend/widgets/ui/calendar_widget.dart';
import 'package:rgntrainer_frontend/widgets/ui/navbar_widget.dart';
import 'package:rgntrainer_frontend/widgets/ui/title_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/date_symbol_data_local.dart';

class DiagramScreen extends StatefulWidget {
  @override
  _DiagramScreenState createState() => _DiagramScreenState();
}

class _DiagramScreenState extends State<DiagramScreen> {
  late User _currentUser = User.init();
  AdminCallsProvider adminCalls = AdminCallsProvider();

  @override
  void initState() {
    super.initState();
    _currentUser = UserSimplePreferences.getUser();
    initializeDateFormatting(); //Set language of CalendarWidget to German
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
                  TitleWidget("Diagramme"),
                  MediaQuery.of(context).size.width > 1500
                      ? Expanded(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 800),
                            color: Colors.grey[100],
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    constraints: BoxConstraints(minHeight: 800),
                                    padding: EdgeInsets.all(100),
                                    height: double.infinity,
                                    color: Colors.grey[100],
                                    child: LineChartWidget(
                                      callType: CallType.Standart,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    constraints: BoxConstraints(minHeight: 800),
                                    padding: EdgeInsets.all(100),
                                    height: double.infinity,
                                    color: Colors.grey[100],
                                    child: LineChartWidget(
                                      callType: CallType.Anrufbeantworter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                            children: [
                              Container(
                                height: 800,
                                padding: EdgeInsets.all(50),
                                color: Colors.grey[100],
                                child: LineChartWidget(
                                  callType: CallType.Standart,
                                ),
                              ),
                              Container(
                                height: 800,
                                padding: EdgeInsets.all(50),
                                color: Colors.grey[100],
                                child: LineChartWidget(
                                  callType: CallType.Anrufbeantworter,
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
