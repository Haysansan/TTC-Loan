import 'package:apploan/models/customer/model.dart';
import 'package:apploan/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apploan/core/core.dart';
import 'package:apploan/views/customers/widgets/customer_detail_view.dart';

class CustomersItemWidget extends StatelessWidget {
  const CustomersItemWidget({Key? key, required this.client}) : super(key: key);

  final ClientModel client;

  static const _avatarColors = [
    Color(0xFFB7EFC5), // green
    Color(0xFFA8DAFB), // blue
    Color(0xFFD8D3F8), // grey-purple
    Color(0xFFFAD0B1), // orange
    Color(0xFFF7C9D4), // pink
    Color(0xFFE3D5A8), // tan
    Color(0xFFD7C7F0), // purple
  ];

  Color get _avatarColor =>
      _avatarColors[client.displayName.hashCode.abs() % _avatarColors.length];

  String get _initials {
    final parts = client.displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => CustomerDetailView(client: client)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  color: _avatarColor,
                  child:
                      client.photo.isNotEmpty
                          ? CustomNetworkImage(
                            imageUrl: client.photo,
                            width: 64,
                            height: 64,
                          )
                          : Center(
                            child: Text(
                              _initials,
                              style: AppTextStyle.mediumPrimaryBold,
                            ),
                          ),
                ),
              ),
              12.width,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: client.displayName,
                          style: AppTextStyle.mediumPrimaryBold,
                          children: [
                            TextSpan(
                              text: ' (${client.client_code})',
                              style: AppTextStyle.smallGreyRegular,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      Text(
                        client.mobile,
                        style: AppTextStyle.midPrimaryBold.copyWith(
                          color: AppColor.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      2.height,
                      Text(
                        client.address,
                        style: AppTextStyle.smallGreyRegular,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
              Positioned(top: 0, right: 0, child: _trailing()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailing() {
    if (UserRepository.shared.isCO) {
      return GestureDetector(
        onTap: () => Get.toNamed(Routes.loandisbursments),
        child: Text(
          'Open Loan',
          style: AppTextStyle.smallPrimaryBold.copyWith(color: AppColor.red),
        ),
      );
    }
    return const Icon(Icons.more_vert, color: AppColor.grey400, size: 20);
  }
}
