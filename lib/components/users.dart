import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/main.dart';
import 'package:stash_app/services/collections.dart';
import 'package:stash_app/services/users.dart';
import 'package:stash_app/store.dart';
import 'package:url_launcher/url_launcher.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Future<List<User>> fetchData() async {
    final user = context.get<Signal<User?>>();
    return await usersList(user.value!.token);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.get<Signal<User?>>();

    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        Widget newUserDialog() => AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                child: const ShadCard(
                  title: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShadImage.square(size: 16, LucideIcons.plus)),
                  description: Text("Crear un nuevo usuario"),
                ),
                onTap: () async {
                  showShadDialog(
                    context: context,
                    builder: (context) => ShadDialog(
                      title: const Text(
                          textAlign: TextAlign.left, 'Nuevo usuario'),
                      description: const Text(
                          textAlign: TextAlign.left,
                          "Introduce los datos del nuevo usuario."),
                      content: Container(
                        width: 375,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShadForm(
                              child: Column(
                                children: [
                                  ShadInputFormField(
                                    id: 'username',
                                    label: const Text('Nombre de usuario'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Por favor, introduce un nombre.';
                                      }

                                      return null;
                                    },
                                  ),
                                  ShadInputFormField(
                                    id: 'email',
                                    label: const Text('Email'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Por favor, introduce un email.';
                                      }

                                      return null;
                                    },
                                  ),
                                  ShadInputFormField(
                                    id: 'password',
                                    label: const Text('Contraseña'),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Por favor, introduce una contraseña.';
                                      }

                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        ShadButton.ghost(
                          text: const Text('Cerrar'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ShadButton(
                          text: const Text("Crear"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );

        if (!snapshot.hasData) {
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [newUserDialog()],
          );
        }

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            newUserDialog(),
            ...snapshot.data!.map(
              (user) => AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  child: ShadCard(
                    title: Text(user.username),
                    description: Text(user.email),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          "Rol: ${user.role}",
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Reminder: ${user.reminderDayOfWeek ?? 'Ninguno'}",
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            if (user.role == 'banned')
                              ShadButton.outline(
                                text: Text('Banear'),
                                onPressed: () async {
                                  await usersUnban(
                                      currentUser.value!.token, user.id);
                                  setState(() {});
                                },
                              )
                            else
                              ShadButton.outline(
                                text: Text('Banear'),
                                onPressed: () async {
                                  await usersBan(
                                      currentUser.value!.token, user.id);
                                  setState(() {});
                                },
                              ),
                            const SizedBox(width: 8),
                            ShadButton.destructive(
                              text: const Text("Borrar"),
                              onPressed: () => showShadDialog(
                                context: context,
                                builder: (context) => ShadDialog.alert(
                                  title: const Text(
                                    '¿Estas seguro?',
                                    textAlign: TextAlign.left,
                                  ),
                                  description: const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Esta acción es irreversible. ¿Estás seguro de que quieres eliminar este user?',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  actions: [
                                    ShadButton.ghost(
                                      text: const Text('Cancelar'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    ShadButton.destructive(
                                      text: const Text('Eliminar'),
                                      onPressed: () {
                                        usersDelete(
                                            currentUser.value!.token, user.id);
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
