import 'package:flutter/material.dart';
import 'package:mpos/services/shared_preferences_service.dart';
import 'package:mpos/types/employee.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CashierSelectionDialog extends StatefulWidget {
  const CashierSelectionDialog({
    Key? key,
    required this.rootContext,
  }) : super(key: key);

  final BuildContext rootContext;

  @override
  State<CashierSelectionDialog> createState() => _CashierSelectionDialogState();
}

class _CashierSelectionDialogState extends State<CashierSelectionDialog> {
  List<Employee> employeeList = [];
  bool isLoading = false;
  bool isSubmitting = false;
  Employee? selectedEmployee;
  String? savedEmployeeId; // Store the saved employee ID

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Combined initialization to handle the order properly
  Future<void> _initializeData() async {
    await getSavedEmployeeId(); // Get saved ID first
    await fetchEmployees(); // Then fetch employees and match
  }

  Future<void> getSavedEmployeeId() async {
    final employeeId = await SharedPreferencesService.get('employee_id');
    if (employeeId != null) {
      savedEmployeeId = employeeId;
    }
  }

  Future<void> fetchEmployees() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userId = await SharedPreferencesService.get("user_id");
      final locationName = await SharedPreferencesService.get("location_name");
                  
      if (userId == null) {
        _showSnackBar("User ID not found. Please login again.", isError: true);
        return;
      }
      if (locationName == null) {
        _showSnackBar("Location Name not found. Please login again.", isError: true);
        return;
      }

      final employeesResponse = await Supabase.instance.client
          .from("employees")
          .select("*")
          .eq("user_id", userId)
          .eq("address", locationName);

      setState(() {
        employeeList = employeesResponse
            .map((employee) => Employee.fromMap(employee))
            .toList();
        
        // Now match the saved employee ID with the loaded employees
        if (savedEmployeeId != null) {
          selectedEmployee = employeeList.firstWhere(
            (employee) => employee.id == savedEmployeeId,
            orElse: () => null as Employee, // This will return null if not found
          );
          // Handle the case where orElse returns null
          if (selectedEmployee?.id != savedEmployeeId) {
            selectedEmployee = null;
          }
        }
      });

      if (employeeList.isEmpty) {
        _showSnackBar("No employees found. Please contact support.", isError: true);
      }
    } catch (error) {
      _showSnackBar("Failed to load employees. Please try again. $error", isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveEmployee() async {
    try {
      setState(() {
        isSubmitting = true;
      });
      if (selectedEmployee == null) {
        _showSnackBar("Please select a cashier first.", isError: true);
        return;
      }

      await SharedPreferencesService.save("employee_name", selectedEmployee?.name);
      await SharedPreferencesService.save("employee_id", selectedEmployee?.id);
      _showSnackBar("Successfully saved employee as current cashier", isError: false);
            
      if (mounted) {
        Navigator.of(context).pop(selectedEmployee); // Return selected employee
      }
    } catch (e) {
      _showSnackBar("Error saving cashier: $e", isError: true);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(widget.rootContext).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void onEmployeeChange(Employee? employee) {
    setState(() {
      selectedEmployee = employee;
    });
  }

  Widget _buildEmployeeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              "Select Cashier",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Employee>(
          value: selectedEmployee,
          hint: Text(
            "Choose an employee...",
            style: TextStyle(color: Colors.grey[500]),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: employeeList.map((Employee employee) {
            return DropdownMenuItem<Employee>(
              value: employee, // This will now match properly
              child: Row(
                children: [
                  // Add a small indicator if this is the currently saved employee
                  if (employee.id == savedEmployeeId) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      employee.name,
                      style: TextStyle(
                        fontWeight: employee.id == savedEmployeeId 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onEmployeeChange,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
        ),
        // Show current selection info
        if (savedEmployeeId != null && selectedEmployee?.id == savedEmployeeId) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                "Currently active cashier",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          "Loading employees...",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.person_off_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          "No Employees Found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please contact support to add employees.",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: fetchEmployees,
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_pin,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Cashier",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            "Choose who will be operating the POS",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Content
                if (isLoading)
                  _buildLoadingState()
                else if (employeeList.isEmpty)
                  _buildEmptyState()
                else ...[
                  _buildEmployeeDropdown(),
                  
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: (isSubmitting || selectedEmployee == null) 
                              ? null 
                              : saveEmployee,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Continue",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Selected Employee Preview (if any)
                if (selectedEmployee != null && !isLoading) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Selected: ${selectedEmployee!.name}",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}