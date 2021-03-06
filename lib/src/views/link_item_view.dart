import 'package:flutter/material.dart';
import 'package:linki/src/models/link.dart';
import 'package:linki/src/models/main_model.dart';
import 'package:linki/src/values/status_code.dart';
import 'package:linki/src/values/strings.dart';
import 'package:linki/src/views/login.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'LinkItemView';

class LinkItemView extends StatelessWidget {
  final Link link;

  const LinkItemView({Key key, @required this.link})
      : assert(link != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    _handleReport(model) async {
      StatusCode reportStatus = await model.report(link);
      switch (reportStatus) {
        case StatusCode.success:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(reportSubmittedMessage),
          ));
          break;
        case StatusCode.failed:
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
          ));
          break;
        default:
          print('$_tag unexpected report status: $reportStatus');
      }
    }

    _showLoginDialog( Intent intent) async => await showDialog(
        context: context, builder: (context) => LoginDialog(intent: intent));

    _handleMenuActions(MainModel model, MenuOption option) {
      switch (option) {
        case MenuOption.open:
          model.openLink(link);
          break;
        case MenuOption.delete:
          model.deleteLink(link);
          break;
        case MenuOption.share:
          model.share(link);
          break;
        case MenuOption.report:
          model.isLoggedIn
              ? _handleReport(model)
              : _showLoginDialog( Intent.login);
          break;
        default:
          print('$_tag unexpected menu option $option');
      }
    }

    _buildPopUpMenuButton(MainModel model, bool isLinkOwner) =>
        PopupMenuButton<MenuOption>(
          onSelected: (option) => _handleMenuActions(model, option),
          itemBuilder: (
            _,
          ) =>
              <PopupMenuEntry<MenuOption>>[
                const PopupMenuItem(
                  child: Text(openText),
                  value: MenuOption.open,
                ),
                const PopupMenuItem(
                  child: Text(shareText),
                  value: MenuOption.share,
                ),
                PopupMenuItem(
                  child: Text(isLinkOwner ? deleteText : reportText),
                  value: isLinkOwner ? MenuOption.delete : MenuOption.report,
                )
              ],
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        bool isLinkOwner = model.isLoggedIn &&
            (model.currentUser.id == link.createdBy ||
                model.currentUser.isAdmin);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.black12,
            backgroundImage: link.imageUrl != null
                ? NetworkImage(link.imageUrl)
                : AssetImage('assets/icon-foreground.png'),
          ),
          title: Text(link.decodedTitle, softWrap: true,),
          subtitle: Text(link.decodedDescription, softWrap: true,),
          trailing: _buildPopUpMenuButton(model, isLinkOwner),
          onTap: () => model.openLink(link),
        );
      },
    );
  }
}
