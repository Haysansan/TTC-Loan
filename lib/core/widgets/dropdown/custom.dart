import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';
import 'package:get/get.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.initValue,
    this.hintText,
    this.validator,
    this.isReason = true,
    this.color,
  }) : super(key: key);

  final List<dynamic> items;
  final Function(String) onChanged;
  final String? hintText;
  final String? initValue;
  final String? Function(String?)? validator;
  final bool isReason;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: initValue,
      onChanged: (value) => onChanged(value!),
      validator: validator,
      dropdownColor: AppColor.white,
      style: const TextStyle(color: AppColor.primaryText, fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColor.white,
        hintText: hintText,
        hintStyle: AppTextStyle.normalLightGreyRegular,
        contentPadding: 15.padHorizontal,
        border: OutlineInputBorder(borderRadius: UIConstants.radius.radiusAll),
        focusedBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
        ),
      ),
      items:
          items.map<DropdownMenuItem<String>>((dynamic value) {
            return DropdownMenuItem<String>(
              value:
                  isReason ? value.id.toString() : value.deliverId.toString(),
              child: Text(
                value.name ?? 'N/A',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color),
              ),
            );
          }).toList(),
    );
  }
}

class MultiSelectDropdown<T> extends StatelessWidget {
  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onChanged,
    this.hintText,
    this.validator,
  }) : super(key: key);

  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final Function(List<T>) onChanged;
  final String? hintText;
  final String? Function(List<T>?)? validator;

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder:
          (_) => _MultiSelectPicker<T>(
            items: items,
            selectedItems: List.from(selectedItems),
            itemLabel: itemLabel,
            onConfirm: onChanged,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
      validator: validator != null ? (_) => validator!(selectedItems) : null,
      builder:
          (state) => GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: 15.padHorizontal,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: UIConstants.radius.radiusAll,
                border: Border.all(color: AppColor.lightGrey, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        selectedItems.isEmpty
                            ? Text(
                              hintText ?? '',
                              style: AppTextStyle.normalLightGreyRegular,
                            )
                            : Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children:
                                  selectedItems
                                      .map(
                                        (item) => Chip(
                                          label: Text(
                                            itemLabel(item),
                                            style:
                                                AppTextStyle
                                                    .normalPrimaryRegular,
                                          ),
                                          backgroundColor: AppColor.lightGrey,
                                          padding: EdgeInsets.zero,
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 14,
                                          ),
                                          onDeleted: () {
                                            final updated = List<T>.from(
                                              selectedItems,
                                            )..remove(item);
                                            onChanged(updated);
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColor.lightGrey),
                ],
              ),
            ),
          ),
    );
  }
}

class _MultiSelectPicker<T> extends StatefulWidget {
  const _MultiSelectPicker({
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onConfirm,
  });

  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final Function(List<T>) onConfirm;

  @override
  State<_MultiSelectPicker<T>> createState() => _MultiSelectPickerState<T>();
}

class _MultiSelectPickerState<T> extends State<_MultiSelectPicker<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        ListView(
          shrinkWrap: true,
          children:
              widget.items
                  .map(
                    (item) => CheckboxListTile(
                      value: _selected.contains(item),
                      title: Text(
                        widget.itemLabel(item),
                        style: AppTextStyle.normalPrimaryRegular,
                      ),
                      activeColor: AppColor.red,
                      onChanged: (checked) {
                        setState(() {
                          checked == true
                              ? _selected.add(item)
                              : _selected.remove(item);
                        });
                      },
                    ),
                  )
                  .toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            text: LocaleKeys.submit.tr,
            onPressed: () {
              widget.onConfirm(_selected);
              Get.back();
            },
          ),
        ),
      ],
    );
  }
}
