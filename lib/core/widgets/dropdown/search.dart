import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';

class SearchDropDown<T> extends StatelessWidget {
  const SearchDropDown({
    Key? key,
    required this.items,
    required this.onChanged,
    required this.itemAsString,
    this.selectedItem,
    this.label,
  }) : super(key: key);

  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T) itemAsString;
  final T? selectedItem;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: items,
      itemAsString: itemAsString,
      selectedItem: selectedItem,
      onChanged: onChanged,
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: const TextStyle(color: AppColor.primaryText, fontSize: 12),
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 12.0),
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
