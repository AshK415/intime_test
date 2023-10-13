import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intime_test/src/core/core.dart';
import 'package:intime_test/src/core/routes/routes_location.dart';
import 'package:intime_test/src/features/auth/auth.dart';
import 'package:intime_test/src/features/conversation/presentation/providers/providers.dart';
import 'package:intime_test/src/features/conversation/presentation/screens/message/chat_screen.dart';
import 'package:intime_test/src/features/conversation/presentation/widgets/widgets.dart';
import 'package:intime_test/src/utils/extensions.dart';

class ConversationScreen extends HookConsumerWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageVisibility = useState(true);
    final conversationController = ref.watch(conversationNotifierProvider);

    return Scaffold(
      backgroundColor: ColorConstants.colorWhite,
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                ref.read(authControllerProvider).logoutUser();
              },
              icon: const Icon(Icons.logout_rounded)),
        ],
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: conversationController.when(
              data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      messageVisibility.value
                          ? MessageBanner(
                              backgroundColor: ColorConstants.colorBg10,
                              message: StringConstants.messageText,
                              onDismiss: () {
                                messageVisibility.value = false;
                              },
                            )
                          : const SizedBox.shrink(),
                      16.hgap(),
                      const CustomSearchBar(),
                      4.hgap(),
                      Text(
                        StringConstants.infoText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF20335B),
                        ),
                      ),
                      16.hgap(),
                      SelectionList(
                        options: data.filters!
                            .map((e) => OptionsModel(
                                  leading: SvgPicture.asset(
                                    e['prefixIcon'],
                                    color: e['isActive'] ? Colors.white : null,
                                  ),
                                  title: e['name'],
                                  isActive: e['isActive'],
                                  data: e,
                                ))
                            .toList(),
                        onOptionClicked: (m) {
                          ref
                              .read(conversationNotifierProvider.notifier)
                              .onOptionsSelected(m.data);
                        },
                      ),
                      16.hgap(),
                      data.isLoading
                          ? const Expanded(
                              child: Center(
                              child: CircularProgressIndicator(),
                            ))
                          : const SizedBox.shrink(),
                      if (data.chatContacts != null)
                        Flexible(
                          child: ListView.builder(
                            itemCount: data.chatContacts?.length,
                            shrinkWrap: true,
                            itemBuilder: (c, i) => Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ConversationListTile(
                                leading: UserProfileWidget(
                                  profileImage:
                                      data.chatContacts?[i].profilePic,
                                  onClick: () {
                                    debugPrint('I got clicked');
                                  },
                                ),
                                onClick: () {
                                  context.go(
                                      '${RoutesLocation.conversation}/chat',
                                      extra: {
                                        'name': data.chatContacts?[i].name,
                                        'uid': data.chatContacts?[i].contactId,
                                        'profilePic':
                                            data.chatContacts?[i].profilePic
                                      });

                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (ctx) => const ChatScreen(
                                  //         name: 'Patient3',
                                  //         uid: 'gpfHuEuehdP9OiIsSzJlxgOBuhB3',
                                  //         profilePic:
                                  //             'https://i.pravatar.cc/100')));
                                },
                                trailing: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Center(
                                      child: SvgPicture.asset(
                                    i % 2 == 0
                                        ? CustomIcons.normalChatIcon
                                        : CustomIcons.activeChatIcon,
                                  )),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.chatContacts?[i].name ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                        data.chatContacts?[i].lastMessage ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              error: (_, __) => const Center(
                    child: Text('Got some error while fetching data..'),
                  ),
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  )),
        ),
      ),
    );
  }
}
