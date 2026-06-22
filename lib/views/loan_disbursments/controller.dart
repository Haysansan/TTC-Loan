import 'package:apploan/core/core.dart';
import 'package:apploan/core/offline/database_helper.dart';
import 'package:apploan/models/models.dart';
import 'package:apploan/routes.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apploan/views/views.dart';

class LoanDisbursmentsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController instCtl = TextEditingController();
  final TextEditingController intCtl = TextEditingController();
  final TextEditingController addminFeeCtl = TextEditingController();
  final TextEditingController dateOpenLoanCtl = TextEditingController();
  final TextEditingController dateFirstRepaymentCtl = TextEditingController();
  final TextEditingController dailyIncomeCtl = TextEditingController();
  final TextEditingController totalDebtCtl = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingClients = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingProductDetail = false.obs;
  final RxBool isLoadingLoanPurpose = false.obs;
  final RxBool isLoadingDailyIncome = false.obs;

  final RxString loggedUserName = ''.obs;

  final RxList<FrequencyTypeModel> frequencyTypeList =
      <FrequencyTypeModel>[].obs;
  final RxList<DailyIncomeModel> dailyIncomeTypeList = <DailyIncomeModel>[].obs;
  final RxList<ProductModel> productList = <ProductModel>[].obs;
  final RxList<ClientDisbModel> clientList = <ClientDisbModel>[].obs;
  final RxList<AppliedAmountModel> appliedAmountList =
      <AppliedAmountModel>[].obs;
  final RxList<LoanPurposeModel> loanPurposeList = <LoanPurposeModel>[].obs;

  final Rxn<FrequencyTypeModel> selectedFrequency = Rxn<FrequencyTypeModel>();
  final Rxn<DailyIncomeModel> selectedDailyIncome = Rxn<DailyIncomeModel>();
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final Rxn<ClientDisbModel> selectedClient = Rxn<ClientDisbModel>();
  final Rxn<AppliedAmountModel> selectedAppliedAmount =
      Rxn<AppliedAmountModel>();
  final Rxn<LoanPurposeModel> selectedLoanPurpose = Rxn<LoanPurposeModel>();
  final RxList<FeeModel> feeList = <FeeModel>[].obs;
  final RxList<FeeModel> selectedFees = <FeeModel>[].obs;
  // final RxList<DailyIncomeModel> dailyIncomeList = <DailyIncomeModel>[].obs;

  final RxList<ProductTypeModel> productTypeList = <ProductTypeModel>[].obs;
  final Rxn<ProductTypeModel> selectedProductType = Rxn<ProductTypeModel>();
  final RxBool isLoadingProductTypes = false.obs;

  void onFeeChanged(List<FeeModel> fees) => selectedFees.assignAll(fees);
  // void onDailyInomeChanged(List<DailyIncomeModel> dailyincome) =>
  //     selectedDailyIncome.assignAll(dailyincome);

  @override
  void onInit() async {
    final now = DateTime.now();
    dateOpenLoanCtl.text = DateFormat('yyyy-MM-dd').format(now);
    dateFirstRepaymentCtl.text = DateFormat(
      'yyyy-MM-dd',
    ).format(now.add(const Duration(days: 1)));

    _loadHardcodedFrequencyTypes(); // sync, call directly

    await Future.wait([
      _loadUserAndClients(),
      // fetchFrequencyTypes(),
      fetchProductTypes(),
      fetchLoanCreate(),
      fetchDailyIncome(),
    ]);
    super.onInit();
  }

  // @override
  // void onInit() async {
  //   final now = DateTime.now();
  //   dateOpenLoanCtl.text = DateFormat('yyyy-MM-dd').format(now);
  //   dateFirstRepaymentCtl.text = DateFormat(
  //     'yyyy-MM-dd',
  //   ).format(now.add(const Duration(days: 1)));

  //   await Future.wait([
  //     _loadUserAndClients(),
  //     // fetchFrequencyTypes(),
  //     fetchProductTypes(),
  //     fetchLoanCreate(),
  //   ]);
  //   super.onInit();
  // }

  Future<int?> _getBranchId() =>
      SharedPreferencesManager.getIntValue('branch_id');
  Future<int?> _getUserId() => SharedPreferencesManager.getIntValue('user_id');

  Future<void> _loadUserAndClients() async {
    final name = await SharedPreferencesManager.get('name');
    loggedUserName.value = name as String? ?? '';
    final userId = await _getUserId();
    if (userId != null) await fetchClients(userId);
  }

  void _loadHardcodedFrequencyTypes() {
    frequencyTypeList.assignAll([
      FrequencyTypeModel.fromJson({'id': '1days', 'name': '១ ថ្ងៃ'}),
      FrequencyTypeModel.fromJson({'id': '1weeks', 'name': '១ សប្តាហ៍'}),
      FrequencyTypeModel.fromJson({'id': '2weeks', 'name': '២ សប្តាហ៍'}),
      FrequencyTypeModel.fromJson({'id': '1months', 'name': '១ ខែ'}),
    ]);
  }

  // Reads [cacheKey] from the local DB cache if present; otherwise calls
  // [fetcher] for fresh data and stores the result for next time, so the
  // API is only hit once per device for a given lookup list.
  Future<List<Map<String, dynamic>>> _cachedOrFetch(
    String cacheKey,
    Future<List<Map<String, dynamic>>> Function() fetcher,
  ) async {
    final cached = await DatabaseHelper.instance.getCachedLookupList(cacheKey);
    if (cached != null) return cached;
    final fresh = await fetcher();
    await DatabaseHelper.instance.cacheLookupList(cacheKey, fresh);
    return fresh;
  }

  Future<void> fetchLoanCreate() async {
    try {
      final rows = await _cachedOrFetch('disb_loan_create', () async {
        final res = await Get.find<ApiService>().get(
          EndPoints.loanCreate,
          isShowLoading: false,
        );
        return [Map<String, dynamic>.from(res.data as Map)];
      });
      final data = rows.first;
      appliedAmountList.assignAll(
        ((getPropertyFromJson(data, 'applied_amount_dis') as List?) ?? []).map(
          (e) => AppliedAmountModel.fromJson(e),
        ),
      );
      loanPurposeList.assignAll(
        ((getPropertyFromJson(data, 'loan_purposes') as List?) ?? []).map(
          (e) => LoanPurposeModel.fromJson(e),
        ),
      );
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    }
  }

  Future<void> fetchProducts(String productType, String frequencyType) async {
    try {
      isLoadingProducts.value = true;
      final branchId = await _getBranchId();
      final cacheKey =
          'disb_products_${branchId}_${productType}_$frequencyType';
      final data = await _cachedOrFetch(cacheKey, () async {
        final res = await Get.find<ApiService>().get(
          EndPoints.getProByFrequencyType,
          queryParameters: {
            'branch_id': branchId,
            'product_type': productType,
            'repayment_frequency_type': frequencyType,
            'currency_id': 2,
          },
          isShowLoading: false,
        );
        return (getPropertyFromJson(res.data, 'data') as List)
            .cast<Map<String, dynamic>>();
      });
      productList.assignAll(data.map((e) => ProductModel.fromJson(e)));
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> fetchProductTypes() async {
    try {
      isLoadingProductTypes.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.getProductType,
        isShowLoading: false,
      );
      final data = (getPropertyFromJson(res.data, 'data') as List)
          .cast<Map<String, dynamic>>();
      productTypeList.assignAll(data.map((e) => ProductTypeModel.fromJson(e)));
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadingProductTypes.value = false;
    }
  }

  Future<void> fetchProductDetail(num id) async {
    try {
      isLoadingProductDetail.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.getproduct_detail,
        queryParameters: {'id': id},
        isShowLoading: false,
      );
      final data = getPropertyFromJson(res.data, 'data') as List<dynamic>;
      if (data.isNotEmpty) {
        final product = ProductDetailModel.fromJson(data.first);
        instCtl.text = (product.loan_term ?? 0).toString();
        intCtl.text = product.interest_rate ?? '0.000';
        // addminFeeCtl.text = product.fee ?? '0.000';
      }
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadingProductDetail.value = false;
    }
  }

  Future<void> fetchClients(num userId) async {
    final branchId = await _getBranchId();
    try {
      isLoadingClients.value = true;
      final res = await Get.find<ApiService>().get(
        EndPoints.getClientDisb,
        queryParameters: {'branch_id': branchId, 'user_id': userId},
        isShowLoading: false,
      );
      final data = (getPropertyFromJson(res.data, 'data') as List)
          .cast<Map<String, dynamic>>();
      clientList.assignAll(data.map((e) => ClientDisbModel.fromJson(e)));
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadingClients.value = false;
    }
  }

  // Future<void> fetchFees(num productId) async {
  //   try {
  //     final branchId = await _getBranchId();
  //     final cacheKey = 'disb_fees_${branchId}_$productId';
  //     final data = await _cachedOrFetch(cacheKey, () async {
  //       final res = await Get.find<ApiService>().get(
  //         EndPoints.getFeeByProduct,
  //         queryParameters: {
  //           'branch_id': branchId,
  //           'loan_product_id': productId,
  //         },
  //         isShowLoading: false,
  //       );

  //       return (getPropertyFromJson(res.data, 'data') as List? ?? [])
  //           .cast<Map<String, dynamic>>();
  //     });
  //     feeList.assignAll(data.map((e) => FeeModel.fromJson(e)));
  //   } catch (e) {
  //     if (!isClosed) ExceptionHandler.handleException(e);
  //   }
  // }

  Future<void> fetchDailyIncome() async {
    try {
      isLoadingDailyIncome.value = true;
      final data = await _cachedOrFetch('disb_daily_income', () async {
        final res = await Get.find<ApiService>().get(
          EndPoints.getDailyIncome,
          isShowLoading: false,
        );
        return (getPropertyFromJson(res.data, 'data') as List? ?? [])
            .cast<Map<String, dynamic>>();
      });
      dailyIncomeTypeList.assignAll(
        data.map((e) => DailyIncomeModel.fromJson(e)),
      );
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    } finally {
      isLoadingDailyIncome.value = false;
    }
  }

  // Future<void> onFrequencyChanged(String id) async {
  //   if (selectedFrequency.value?.id == id) return;
  //   final frequency = frequencyTypeList.firstWhereOrNull((f) => f.id == id);
  //   selectedFrequency.value = frequency;
  //   _clearProductFields();
  //   if (frequency != null) await fetchProducts(frequency.id);
  // }
  Future<void> onFrequencyChanged(String id) async {
    if (selectedFrequency.value?.id == id) return;
    selectedFrequency.value = frequencyTypeList.firstWhereOrNull(
      (f) => f.id == id,
    );
    _clearProductSelection();
    await _maybeFetchProducts();
  }

  Future<void> onDailyIncomeChanged(String id) async {
    if (selectedDailyIncome.value?.id.toString() == id) return;
    selectedDailyIncome.value = dailyIncomeTypeList.firstWhereOrNull(
      (f) => f.id.toString() == id,
    );
    // _clearProductSelection();
    // await _maybeFetchProducts();
  }

  Future<void> _maybeFetchProducts() async {
    final type = selectedProductType.value;
    final freq = selectedFrequency.value;
    if (type == null || freq == null) return;
    await fetchProducts(type.name, freq.id);
  }

  Future<void> onProductChanged(String id) async {
    final product = productList.firstWhereOrNull((p) => p.id.toString() == id);
    selectedProduct.value = product;
    if (product != null) {
      instCtl.text = product.loan_term == 'N/A' ? '' : product.loan_term;
      intCtl.text = product.interest_rate == 'N/A' ? '' : product.interest_rate;
      await fetchFees(product.id);
    }
  }

  Future<void> onProductTypeChanged(String id) async {
    if (selectedProductType.value?.id == id) return;
    selectedProductType.value = productTypeList.firstWhereOrNull(
      (p) => p.id == id,
    );
    _clearProductSelection();
    await _maybeFetchProducts();
  }

  void onClientChanged(ClientDisbModel? client) =>
      selectedClient.value = client;

  void onAppliedAmountChanged(String id) {
    selectedAppliedAmount.value = appliedAmountList.firstWhereOrNull(
      (a) => a.id.toString() == id,
    );
  }

  void onLoanPurposeChanged(LoanPurposeModel? value) {
    selectedLoanPurpose.value = value;
  }

  void _clearProductFields() {
    instCtl.clear();
    intCtl.clear();
    addminFeeCtl.clear();
    // dailyIncomeCtl.clear();
  }

  void _clearProductSelection() {
    productList.clear();
    selectedProduct.value = null;
    feeList.clear();
    selectedFees.clear();
    // dailyIncomeList.clear();
    _clearProductFields();
  }

  DatePicker getDatePicker() => DatePicker(
    controller: dateOpenLoanCtl,
    initialDate:
        dateOpenLoanCtl.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(dateOpenLoanCtl.text),
    minDate: DateTime(DateTime.now().year),
    maxDate: DateTime(DateTime.now().year + 200),
    minYear: DateTime.now().year,
    maxYear: DateTime.now().year + 200,
  );

  DatePicker getDateFirstPicker() => DatePicker(
    controller: dateFirstRepaymentCtl,
    initialDate:
        dateFirstRepaymentCtl.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(dateFirstRepaymentCtl.text),
    minDate: DateTime(DateTime.now().year),
    maxDate: DateTime(DateTime.now().year + 200),
    minYear: DateTime.now().year,
    maxYear: DateTime.now().year + 200,
  );

  Future<void> fetchFees(num productId) async {
    try {
      final branchId = await _getBranchId();
      final cacheKey = 'disb_fees_${branchId}_$productId';
      final data = await _cachedOrFetch(cacheKey, () async {
        final res = await Get.find<ApiService>().get(
          EndPoints.getFeeByProduct,
          queryParameters: {
            'branch_id': branchId,
            'loan_product_id': productId,
          },
          isShowLoading: false,
        );

        return (getPropertyFromJson(res.data, 'data') as List? ?? [])
            .cast<Map<String, dynamic>>();
      });
      feeList.assignAll(data.map((e) => FeeModel.fromJson(e)));
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    }
  }

  Future<void> submitBooking() async {
    try {
      final branchId = await _getBranchId();
      final userId = await _getUserId();

      final formData = dio.FormData.fromMap({
        'branch_id': branchId,
        'user_id': userId,
        'client_id': selectedClient.value?.id,
        'loan_product_id': selectedProduct.value?.id,
        'loan_term': instCtl.text,
        'interest_rate': intCtl.text,
        'first_payment_date': dateFirstRepaymentCtl.text,
        'disbursed_date': dateOpenLoanCtl.text,
        'income_disburment': selectedDailyIncome.value?.id,
        'total_debt': totalDebtCtl.text,
        'loan_purpose_id': selectedLoanPurpose.value?.id,
        'applied_amount': selectedAppliedAmount.value?.amountLoans,
        'loan_officer_id': userId,
      });

      for (final f in selectedFees) {
        formData.fields.add(MapEntry('fee[]', f.id.toString()));
      }

      await Get.find<ApiService>().post(
        EndPoints.storeDisburment,
        formData,
        isShowLoading: true,
      );

      DialogManager.showDialog(
        title: LocaleKeys.successfully.tr,
        subTitle: LocaleKeys.youHavesuccessfullyCreatedTheBooking.tr,
        onPressed: () {
          Get.offNamed(Routes.loanDisbursmentsList);
          Get.find<DisburmentListController>().fetchDisburmentList();
        },
      );
    } catch (e) {
      if (!isClosed) ExceptionHandler.handleException(e);
    }
  }
}
