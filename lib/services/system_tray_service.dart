import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayService {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  Future<void> init(BuildContext context) async {
    String iconPath = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

    // We first init the systray menu
    await _systemTray.initSystemTray(
      title: "Task Reminder",
      iconPath: iconPath,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Open',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuItemLabel(
        label: 'About',
        onClicked: (menuItem) {
          windowManager.show(); // Ensure window is visible to show dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('About Task Reminder'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Task Reminder App v1.0'),
                   SizedBox(height: 8),
                   Text('By Bounthong'),
                   Text('Phone/Whatsapps: +856 2091316541'),
                   Text('Email: bounthongvxy@gmail.com'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) async {
          await windowManager.destroy(); // Properly close the window/app
        },
      ),
    ]);

    // set context menu
    await _systemTray.setContextMenu(menu);

    // handle system tray left click
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        windowManager.show();
        windowManager.focus();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
}
