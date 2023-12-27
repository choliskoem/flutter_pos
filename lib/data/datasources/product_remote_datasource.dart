import 'package:dartz/dartz.dart';
import 'package:flutter_pos/core/constants/variables.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pos/data/models/response/product_response_model.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProduct() async {
    final autData = await AuthLocalDatasource().getAuthData();
    final response = await http
        .get(Uri.parse('${Variables.baseUrl}/api/products'), headers: {
      'Authorization': 'Bearer ${autData.token}',
    });
    if (response.statusCode == 200) {
      return right(ProductResponseModel.fromJson(response.body));
    } else {
      return left(response.body);
    }
  }
}
