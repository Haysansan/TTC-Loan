import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/core/core.dart';
import 'package:dropdown_search/dropdown_search.dart';

class BorrowerFieldLabel extends StatelessWidget {
  const BorrowerFieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          children:
              required
                  ? const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                  ]
                  : [],
        ),
      ),
    );
  }
}

class BorrowerDatePickerField extends StatelessWidget {
  const BorrowerDatePickerField({required this.obs});

  final Rxn<DateTime> obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = obs.value;
      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (picked != null) obs.value = picked;
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null
                    ? DateFormat('yyyy-MM-dd').format(date)
                    : 'YYYY-MM-DD',
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      );
    });
  }
}

class BorrowerGenderDropdown extends StatelessWidget {
  const BorrowerGenderDropdown({required this.selected, required this.options});

  final RxnString selected;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownSearch<String>(
        items: options,
        selectedItem: selected.value,
        itemAsString: (item) => item,
        onChanged: (value) => selected.value = value,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        popupProps: PopupProps.menu(showSearchBox: false),
      ),
    );
  }
}

class BorrowerIdTypeDropdown<T> extends StatelessWidget {
  const BorrowerIdTypeDropdown({required this.selected, required this.items});

  final Rxn<T> selected;
  final RxList<T> items;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownSearch<T>(
        items: items,
        selectedItem: selected.value,
        itemAsString: (item) => (item as dynamic).name as String,
        onChanged: (value) => selected.value = value,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        popupProps: PopupProps.menu(showSearchBox: false),
      ),
    );
  }
}

class BorrowerSubmitButton extends StatelessWidget {
  const BorrowerSubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: const Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

InputDecoration borrowerInputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.grey.shade300),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColor.primary),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColor.primary),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColor.primary),
  ),
);
