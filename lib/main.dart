import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeView(),
    );
  }
}

class PageItem {
  final String url;
  double? rate = 0.0;
  Rect rect = Rect.zero;

  PageItem({
    required this.url,
    this.rate,
  });
}

final gPages = <PageItem>[
  PageItem(url: 'http://spsms.dyndns.org:3100/images/nature/nature03.jpg'),
  PageItem(url: 'http://spsms.dyndns.org:3100/images/nature/nature05.jpg'),
  PageItem(url: 'http://spsms.dyndns.org:3100/images/nature/nature09.jpg'),
  PageItem(url: 'http://spsms.dyndns.org:3100/images/nature/nature10.jpg'),
];

void useEffectOnce(Dispose? Function() effect) => useEffect(effect, []);

class HomeView extends HookWidget {
  const HomeView({super.key});

  static const fraction = 1.0;
  static const pageHeight = 300.0;
  static const pageWidth = 375.0 * fraction;

  @override
  Widget build(BuildContext context) {
    final controller =
        usePageController(viewportFraction: fraction, initialPage: 1);
    final pages = useRef(gPages);

    useListenable(controller);
    useEffectOnce(() {
      const unitRect = Rect.fromLTWH(
        (375.0 * (1.0 - fraction)) / 2,
        0.0,
        pageWidth,
        pageHeight,
      );

      for (int i = 0; i < gPages.length; i++) {
        gPages[i].rect = unitRect.shift(Offset(i * pageWidth, 0.0));
      }

      return null;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('home', style: TextStyle(fontSize: 16.0)),
      ),
      body: Center(
        child: SizedBox(
          height: 300.0,
          child: PageView.builder(
            controller: controller,
            itemCount: pages.value.length,
            itemBuilder: (context, index) {
              final window = Rect.fromLTWH(
                controller.offset,
                0.0,
                controller.position.viewportDimension,
                pageHeight,
              );
              final direction = controller.position.userScrollDirection;
              final intersect = window.intersect(gPages[index].rect);
              final rate = intersect.width.abs() / pageWidth;
              var alignX = 0.0;

              switch (direction) {
                case ScrollDirection.reverse:
                  alignX = 1.0 - rate;
                  break;
                case ScrollDirection.forward:
                  alignX = rate - 1.0;
                  break;
                case ScrollDirection.idle:
                  alignX = 0.0;
                  break;
              }

              if (index == 1) {
                print(
                  'offset: ${controller.offset.toStringAsFixed(3)} '
                  'index: $index '
                  'direction: $direction '
                  'rate: ${rate.toStringAsFixed(3)} '
                  'alignX: $alignX',
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.35),
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    alignment: Alignment(alignX, 0.0),
                    image: CachedNetworkImageProvider(gPages[index].url),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
