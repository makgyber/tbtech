import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_order.g.dart';

@JsonSerializable(explicitToJson: true)
@Entity(tableName: 'job_orders')
class JobOrder {
  @PrimaryKey()
  final int? id;
  final String code;
  final String summary;
  @JsonKey(name: "target_date")
  final String targetDate;
  @JsonKey(name: "client_name")
  final String clientName;
  @JsonKey(name: "short_address")
  final String? shortAddress;
  final String? site;
  @JsonKey(name: "job_order_type")
  final String jobOrderType;
  final String status;

  JobOrder(
      this.id,
      this.code,
      this.summary,
      this.targetDate,
      this.clientName,
      this.shortAddress,
      this.site,
      this.jobOrderType,
      this.status,
      );

  factory JobOrder.fromJson(Map<String, dynamic> json)=>_$JobOrderFromJson(json);
  Map<String, dynamic> toJson() => _$JobOrderToJson(this);
}