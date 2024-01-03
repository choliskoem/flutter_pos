import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/core/assets/assets.gen.dart';
import 'package:flutter_pos/core/components/menu_button.dart';
import 'package:flutter_pos/core/components/spaces.dart';
import 'package:flutter_pos/core/constants/colors.dart';
import 'package:flutter_pos/core/extensions/build_context_ext.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos/presentation/auth/pages/login_page.dart';
import 'package:flutter_pos/presentation/home/bloc/logout/logout_bloc.dart';
import 'package:flutter_pos/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos/presentation/order/models/order_model.dart';
import 'package:flutter_pos/presentation/setting/pages/manage_product_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              MenuButton(
                iconPath: Assets.images.manageProduct.path,
                label: 'Kelola Produk',
                onPressed: () => context.push(const ManageProductPage()),
                isImage: true,
              ),
              const SpaceWidth(15.0),
              MenuButton(
                iconPath: Assets.images.managePrinter.path,
                label: 'Kelola Printer',
                onPressed: () {}, //=> context.push(ManagerPrinterPage()),
                isImage: true,
              ),
            ],
          ),
          const SpaceHeight(60.0),
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeMap(
                  orElse: () {},
                  success: (_) async {
                    await ProductLocalDatasource.instance.removeAllProduct();
                    await ProductLocalDatasource.instance.insertAllProduct(
                      _.products.toList(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('Sync Data Success'),
                      ),
                    );
                  });
            },
            builder: (context, state) {
              return state.maybeWhen(orElse: () {
                return ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(const ProductEvent.fetch());
                  },
                  child: const Text('Sync Data'),
                );
              }, loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
            },
          ),
          const Divider(),
          BlocConsumer<LogoutBloc, LogoutState>(
            listener: (context, state) {
              state.maybeMap(
                  orElse: () {},
                  success: (_) {
                    AuthLocalDatasource().removeAuthData();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  });
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  context.read<LogoutBloc>().add(const LogoutEvent.logout());
                },
                child: const Text('Logout'),
              );
            },
          ),
          const Divider(),
          FutureBuilder<List<OrderModel>>(
              future: ProductLocalDatasource.instance.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].paymentMethod),
                        );
                      },
                      itemCount: snapshot.data!.length,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              })
        ],
      ),
    );
  }
}
