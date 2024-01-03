part of 'order_bloc.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  //loading
  const factory OrderState.loading() = _Loading;
//success
  const factory OrderState.success(
      List<OrderItem> products,
      int totalQuantity,
      int totalPrice,
      String paymentMethod,
      int nominalBayar,
      int idKasir,
      String namaKasir) = _Success;
  //error
  const factory OrderState.error(String message) = _Error;
}
