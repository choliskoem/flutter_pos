import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos/data/models/request/product_request_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_pos/data/datasources/product_remote_datasource.dart';
import 'package:flutter_pos/data/models/response/product_response_model.dart';
import 'package:image_picker/image_picker.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;
  List<Product> products = [];

  ProductBloc(
    this._productRemoteDatasource,
  ) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const ProductState.loading());
      final response = await _productRemoteDatasource.getProduct();
      response.fold((l) => emit(ProductState.error(l)), (r) {
        products = r.data;
        emit(ProductState.success(r.data));
      });
    });
    on<_FetchLocal>((event, emit) async {
      emit(const ProductState.loading());
      final localproducts =
          await ProductLocalDatasource.instance.getAllProduct();
      products = localproducts;
      emit(ProductState.success(products));
    });
    on<_FetchByCategory>((event, emit) async {
      emit(const ProductState.loading());
      final newProducts = event.category == 'all'
          ? products
          : products
              .where((element) => element.category == event.category)
              .toList();
      emit(ProductState.success(newProducts));
    });

    on<_AddProduct>((event, emit) async {
      emit(const ProductState.loading());
      final requestData = ProductRequestModel(
        name: event.product.name,
        price: event.product.price,
        stock: event.product.stock,
        image: event.image,
        category: event.product.category,
        isBestSeller: event.product.isBestSeller ? 1 : 0,
      );
      final response = await _productRemoteDatasource.addProduct(requestData);
      // products.add(newProduct);
      response.fold(
        (l) => emit(ProductState.error(l)),
        (r) {
          products.add(r.data);
          emit(ProductState.success(products));
        },
      );

      emit(ProductState.success(products));
    });
  }
}
