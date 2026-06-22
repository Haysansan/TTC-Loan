import 'package:apploan/core/core.dart';
import 'package:apploan/models/models.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:apploan/views/views.dart';

class AddCustomersView extends GetView<AddCustomersController> {
  const AddCustomersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final coBorrowerCtrl = Get.find<CoBorrowerController>();
    final guarantorCtrl = Get.find<GuarantorController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.addCustomer.tr,
        onBack: () => Navigator.pop(context, false),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.red),
          );
        }
        return Padding(
          padding: UIConstants.spacing.padHorizontal,
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  16.height,
                  // Profile photo
                  Center(
                    child: Obx(() {
                      return GestureDetector(
                        onTap: controller.pickProfileImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColor.lightGrey,
                              backgroundImage:
                                  controller.profileImage.value != null
                                      ? FileImage(
                                        File(
                                          controller.profileImage.value!.path,
                                        ),
                                      )
                                      : null,
                              child:
                                  controller.profileImage.value == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColor.grey,
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColor.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  16.height,
                  // First name / Last name
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'First name',
                          required: true,
                          child: CustomTextField(
                            controller: controller.firstName,
                            hintText: 'First name',
                            textInputAction: TextInputAction.next,
                            validator: (text) => FormValidator.empty(text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: 'Last name',
                          required: true,
                          child: CustomTextField(
                            controller: controller.lastName,
                            hintText: 'Last name',
                            textInputAction: TextInputAction.next,
                            validator: (text) => FormValidator.empty(text),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 16.height,
                  // Gender / Date of birth
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Gender',
                          required: true,
                          child: DropdownSearch<String>(
                            items: controller.genderItems,
                            onChanged:
                                (value) => controller.selectGender(value ?? ''),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: 15.padHorizontal,
                                helperText: ' ',
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColor.lightGrey,
                                    width: 1,
                                  ),
                                  borderRadius: UIConstants.radius.radiusAll,
                                ),
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              showSearchBox: false,
                              menuProps: MenuProps(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(10),
                                positionCallback: (popupButtonObject, overlay) {
                                  final size = popupButtonObject.size;
                                  final topLeft = popupButtonObject
                                      .localToGlobal(
                                        Offset.zero,
                                        ancestor: overlay,
                                      );
                                  final fieldHeight =
                                      size.height -
                                      28; // increase this to move popup up more
                                  return RelativeRect.fromSize(
                                    Rect.fromPoints(
                                      topLeft + Offset(0, fieldHeight),
                                      topLeft + Offset(size.width, fieldHeight),
                                    ),
                                    overlay.size,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: 'Date Of Birth',
                          required: true,
                          child: InkWell(
                            onTap: () => controller.getDatePicker().show(),
                            child: StackTextField(
                              controller: controller.dateOfBirth,
                              hintText: LocaleKeys.chooseDate.tr,
                              validator:
                                  (text) => FormValidator.phoneNumber(text),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 16.height,
                  // Phone / GIS code
                  Row(
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Phone number',
                          required: true,
                          child: CustomTextField(
                            controller: controller.phoneNumber,
                            hintText: 'Phone number',
                            textInputAction: TextInputAction.next,
                            validator: (text) => FormValidator.empty(text),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LabeledField(
                          label: 'GIS',
                          child: Obx(
                            () => CustomTextField(
                              controller: controller.gisCode,
                              hintText: 'Lat/Long',
                              readOnly: true,
                              onTap: controller.fetchCurrentLocation,
                              textInputAction: TextInputAction.next,
                              suffixIcon:
                                  controller.isFetchingLocation.value
                                      ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                      : IconButton(
                                        icon: const Icon(
                                          Icons.my_location,
                                          color: AppColor.primary,
                                        ),
                                        onPressed:
                                            controller.fetchCurrentLocation,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 16.height,
                  // Type of ID
                  Obx(
                    () => LabeledField(
                      label: 'Type of ID',
                      required: true,
                      child: DropdownSearch<CoBorrowerIdTypeModel>(
                        items: controller.idTypes,
                        selectedItem: controller.selectedIdType.value,
                        itemAsString: (item) => item.name,
                        onChanged:
                            (value) => controller.selectedIdType.value = value,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        popupProps: PopupProps.menu(showSearchBox: false),
                      ),
                    ),
                  ),
                  10.height,
                  // National ID
                  LabeledField(
                    label: 'ID Number',
                    required: true,
                    child: CustomTextField(
                      controller: controller.externalIdController,
                      hintText: 'Numbers..',
                      textInputAction: TextInputAction.next,
                      validator: (text) => FormValidator.empty(text),
                    ),
                  ),
                  // 16.height,
                  // ID Card photo (optional)
                  LabeledField(
                    label: 'ID Card Photo',
                    child: Obx(
                      () => _IdCardPicker(
                        image: controller.idCardImage.value,
                        onTap: controller.pickIdCardImage,
                      ),
                    ),
                  ),
                  10.height,
                  // Province / District
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.red,
                              ),
                            );
                          }
                          return LabeledField(
                            label: 'Province / City',
                            required: true,
                            child: SearchDropDown<ProvinceModel>(
                              items: controller.ProvinceList,
                              itemAsString:
                                  (item) => '${item.id} - ${item.name}',
                              onChanged: (value) {
                                controller.ProvinceSelected = value;
                                controller.fetchDistrict(value?.id);
                              },
                              selectedItem: controller.ProvinceSelected,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading_district.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.red,
                              ),
                            );
                          }
                          return LabeledField(
                            label: 'District / Khan',
                            required: true,
                            child: SearchDropDown<DistrictModel>(
                              items: controller.districtList,
                              itemAsString:
                                  (item) => '${item.id} - ${item.name_kh}',
                              onChanged: (value) {
                                controller.DistrictSelected = value;
                                controller.fetchCommune(value?.id);
                              },
                              selectedItem: controller.DistrictSelected,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  10.height,
                  // Commune / Village
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading_commune.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.red,
                              ),
                            );
                          }
                          return LabeledField(
                            label: 'Commune',
                            required: true,
                            child: SearchDropDown<CommuneModel>(
                              items: controller.CommuneList,
                              itemAsString:
                                  (item) => '${item.id} - ${item.name}',
                              onChanged: (value) {
                                controller.CommuneSelected = value;
                                controller.fetchVillage(value?.id);
                              },
                              selectedItem: controller.CommuneSelected,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading_village.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColor.red,
                              ),
                            );
                          }
                          return LabeledField(
                            label: 'Village',
                            required: true,
                            child: SearchDropDown<VillageModel>(
                              items: controller.VillageList,
                              itemAsString:
                                  (item) => '${item.id} - ${item.name}',
                              onChanged:
                                  (value) => controller.VillageSelected = value,
                              selectedItem: controller.VillageSelected,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  10.height,
                  // Co-Borrowers
                  _PeopleSection(
                    label: 'Co-Borrowers',
                    // required: true,
                    addLabel: '+ Add Co-Borrowers',
                    emptyText: 'No Co-Borrowers Selected',
                    added: coBorrowerCtrl.added,
                    getName: (e) => (e as CoBorrowerModel).fullname,
                    onRemove: coBorrowerCtrl.remove,
                    onAdd:
                        () => Get.bottomSheet(
                          FractionallySizedBox(
                            heightFactor: 0.87,
                            child: const CoBorrowerFormSheet(),
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        ),
                  ),
                 10.height,
                  // Guarantors
                  _PeopleSection(
                    label: 'Guarantors',
                    // required: true,
                    addLabel: '+ Add Guarantors',
                    emptyText: 'No Guarantors Selected',
                    added: guarantorCtrl.added,
                    getName: (e) => (e as GuarantorModel).fullname,
                    onRemove: guarantorCtrl.remove,
                    onAdd:
                        () => Get.bottomSheet(
                          FractionallySizedBox(
                            heightFactor: 0.87,
                            child: const GuarantorFormSheet(),
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        ),
                  ),
                  10.height,
                  // Submit
                  PrimaryButton(
                    text: LocaleKeys.submit.tr,
                    onPressed: () async {
                      if (!controller.formKey.currentState!.validate()) return;
                      controller.formKey.currentState!.save();
                      await controller.submitBooking();
                    },
                  ),
                  30.height,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Private widget ───

class _PeopleSection extends StatelessWidget {
  const _PeopleSection({
    required this.label,
    required this.addLabel,
    required this.emptyText,
    required this.added,
    required this.getName,
    required this.onRemove,
    required this.onAdd,
    this.required = false,
  });

  final String label;
  final String addLabel;
  final String emptyText;
  final RxList added;
  final String Function(dynamic) getName;
  final void Function(int) onRemove;
  final VoidCallback onAdd;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: label,
                style: AppTextStyle.normalPrimaryRegular,
                children:
                    required
                        ? const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColor.red),
                          ),
                        ]
                        : [],
              ),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Text(
                addLabel,
                style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.grey300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(() {
            if (added.isEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emptyText,
                    style: AppTextStyle.smallGreyRegular.copyWith(
                      color: AppColor.grey400,
                      fontSize: 14,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColor.grey600),
                ],
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  added.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(
                        getName(entry.value),
                        style: AppTextStyle.smallGreyRegular,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => onRemove(entry.key),
                      backgroundColor: AppColor.white,
                      side: const BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
            );
          }),
        ),
      ],
    );
  }
}

class _IdCardPicker extends StatelessWidget {
  const _IdCardPicker({required this.image, required this.onTap});

  final XFile? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.grey300),
          image:
              image != null
                  ? DecorationImage(
                    image: FileImage(File(image!.path)),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child:
            image == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 32,
                      color: AppColor.grey400,
                    ),
                    8.height,
                    Text(
                      'Tap to take a photo of the ID card',
                      style: AppTextStyle.smallGreyRegular,
                    ),
                  ],
                )
                : Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppColor.white,
                    ),
                  ),
                ),
      ),
    );
  }
}
