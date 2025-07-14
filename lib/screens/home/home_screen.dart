import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:pos_desktop_loop/db/controllers/local_authentication_service.dart';
import 'package:pos_desktop_loop/screens/widgets/custom_drawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'User';
  final authService = AuthService();

  // String

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _setUpBloutoothPrinterPermissions();
  }

  bool enabled = false;

  List<_ChartData> data = [
    _ChartData('Mpesa', 35),
    _ChartData('Bank', 28),
    _ChartData('Cash', 34),
    _ChartData('Others', 40),
  ];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: width * 0.01),
        toolbarHeight: height * 0.1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryGreen,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Container(
            height: width * 0.11,
            width: width * 0.11,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawerWidget(),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: AppColors.naturalBackground),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: height * 0.02),
              Container(
                width: width,
                color: AppColors.naturalBackground,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/finance.png',
                          number: '25,365',
                          title: 'Cash',
                          iconClr: Colors.pink[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/giving.png',
                          number: '10,065',
                          title: 'Bank',
                          iconClr: Colors.blue[50]!,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/giving.png',
                          number: '34,500',
                          title: 'Mpesa',
                          iconClr: Colors.blue[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/money-tag.png',
                          number: '3,000',
                          title: 'Owing',
                          iconClr: Colors.orange[50]!,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/saving.png',
                          number: '5,000',
                          title: 'Owed',
                          iconClr: Colors.green[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/finance.png',
                          number: '25,000',
                          title: 'Cash Pool',
                          iconClr: Colors.pink[50]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ItemCard(width: width, height: height),

              // Stock Summary
              SizedBox(height: height * 0.02),
              Text(
                'Stock Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: height * 0.01),
              ItemTile(
                width: width,
                height: height,
                iconClr: AppColors.accentBackground,
                title: 'Total Products',
                number: '768',
                imgUrl: 'assets/images/products.png',
              ),
              SizedBox(height: height * 0.01),
              ItemTile(
                width: width,
                height: height,
                iconClr: Colors.orange[50]!,
                title: 'Total Products in Stock',
                number: '768',
                imgUrl: 'assets/images/bagg.png',
              ),
              SizedBox(height: height * 0.01),
              ItemTile(
                width: width,
                height: height,
                iconClr: Colors.green[50]!,
                title: 'Total Stock Value',
                number: 'Ksh 76,800',
                imgUrl: 'assets/images/cash-m.png',
              ),
              SizedBox(height: height * 0.02),

              Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: height * 0.02),
              salesOverView(width, height),
              // Financial Overview
              SizedBox(height: height * 0.02),
              Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: height * 0.02),
              Container(
                width: width,
                color: AppColors.naturalBackground,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/finance.png',
                          number: '25,365',
                          title: 'Money In',
                          iconClr: Colors.green[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/giving.png',
                          number: '10,065',
                          title: 'Money Out',
                          iconClr: Colors.red[50]!,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/giving.png',
                          number: '34,500',
                          title: 'Cash Flow',
                          iconClr: Colors.blue[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/money-tag.png',
                          number: '3,000',
                          title: 'Gross Profit',
                          iconClr: Colors.orange[50]!,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/saving.png',
                          number: '5,000',
                          title: 'Gross Profit',
                          iconClr: Colors.green[50]!,
                        ),
                        ItemCard(
                          width: width,
                          height: height,
                          imgUrl: 'assets/images/finance.png',
                          number: '25,000',
                          title: 'Net Profit',
                          iconClr: Colors.pink[50]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Sales Overview
              // Graph
              SizedBox(
                height: height * 0.3,
                width: width,
                child: SfCircularChart(
                  title: ChartTitle(
                    text: 'Sales Overview',
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),

                  series: <CircularSeries<_ChartData, String>>[
                    PieSeries<_ChartData, String>(
                      dataSource: data,
                      xValueMapper: (_ChartData data, _) => data.x,
                      yValueMapper: (_ChartData data, _) => data.y,
                      name: 'Gold',
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Row salesOverView(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.01,
          ),
          width: width * 0.45,
          height: height * 0.2,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Categories',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.14,
                child: ListView.separated(
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: AppColors.neutralBackground,
                      height: 1,
                      thickness: 1,
                    );
                  },
                  itemBuilder: (context, index) {
                    return SimpleListItem(index: index, itemName: 'Braids');
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: height * 0.01,
          ),
          width: width * 0.45,
          height: height * 0.2,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Products',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.01),
              SizedBox(
                height: height * 0.14,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: AppColors.neutralBackground,
                      height: 1,
                      thickness: 1,
                    );
                  },
                  itemBuilder: (context, index) {
                    return SimpleListItem(
                      index: index,
                      itemName: 'Polo Blue Shirt',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void fetchUserData() async {
    var user = await authService.getCurrentUser();
    setState(() {
      userName = user!.fullName;
    });
  }

  void _setUpBloutoothPrinterPermissions() async {
    // request permissions for Bluetooth printing implementation
    // This is a placeholder for the actual implementation
    // You can use a package like `permission_handler` to request permissions
    // For example:
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();
    // PermissionStatus status = await Permission.bluetooth.request();
    // if (status.isGranted) {
    //   setState(() {
    //     enabled = true;
    //   });
    // } else {
    //   setState(() {
    //     enabled = false;
    //   });
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}

class SimpleListItem extends StatelessWidget {
  const SimpleListItem({
    super.key,
    required this.index,
    required this.itemName,
  });
  final int index;
  final String itemName;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 10,
      minVerticalPadding: 3,
      dense: true,
      title: Text(
        '${index + 1}. $itemName',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.width,
    required this.height,
    required this.iconClr,
    required this.title,
    required this.number,
    required this.imgUrl,
  });

  final double width;
  final double height;
  final bool enabled = false;
  final Color iconClr;
  final String title;
  final String number;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.01,
      ),
      height: height * 0.12,
      width: width * 0.45,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: width * 0.15,
            width: width * 0.15,
            decoration: BoxDecoration(
              color: iconClr,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Image.asset(imgUrl, fit: BoxFit.cover)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.width,
    required this.height,
    required this.iconClr,
    required this.title,
    required this.number,
    required this.imgUrl,
  });

  final double width;
  final double height;
  final bool enabled = false;
  final Color iconClr;
  final String title;
  final String number;
  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: height * 0.01,
      ),
      height: height * 0.12,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: width * 0.15,
            width: width * 0.15,
            decoration: BoxDecoration(
              color: iconClr,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Image.asset(imgUrl, fit: BoxFit.cover)),
          ),
          SizedBox(width: width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
