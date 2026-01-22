import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _tasks = [];
  String _filter = 'အားလုံး';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final maps = await _dbHelper.getTasks();
    if (mounted) {
      setState(() {
        _tasks = maps;
      });
    }
  }

  void _filterTasks(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ပုဂ္ဂိုလ်':
      case 'Personal':
        return Colors.pink[400]!;
      case 'အလုပ်':
      case 'Work':
        return Colors.blue[500]!;
      case 'သင်ယူမှု':
      case 'Learning':
        return Colors.orange[500]!;
      default:
        return Colors.grey[400]!;
    }
  }

  List<Map<String, dynamic>> get _filteredTasks {
    switch (_filter) {
      case 'အားလုံး':
        return _tasks;
      case 'ပြီးစီး':
        return _tasks.where((task) => task['is_completed'] == 1).toList();
      case 'ယနေ့':
        return _tasks.where((task) => task['is_completed'] == 0).toList();
      default:
        return [];
    }
  }

  void _toggleTask(int id, bool completed) async {
    final taskIndex = _tasks.indexWhere((t) => t['id'] == id);
    if (taskIndex != -1) {
      await _dbHelper.updateTask(id, {
        'id': id,
        'title': _tasks[taskIndex]['title'],
        'description': _tasks[taskIndex]['description'],
        'is_completed': completed ? 1 : 0,
      });
      _loadTasks();
    }
  }

  // ✅ Delete function with confirmation dialog (Swipe + Long Press)
  void _deleteTask(int id) async {
    final taskIndex = _tasks.indexWhere((t) => t['id'] == id);
    final taskTitle = taskIndex != -1 ? _tasks[taskIndex]['title'] : '';

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning, color: Colors.red[600], size: 24),
            ),
            SizedBox(width: 12.w),
            Text('ဖျက်မည်လား?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$taskTitle"', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text(
              'ဒီ အလုပ်ကို ဖျက်မှာပါ။ ပြန်လည် ပြန်ယူလို့ မရပါ။',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ပယ်ဖျက်', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // Dialog ပိတ်
              await _dbHelper.deleteTask(id); // Database ကနေ ဖျက်
              _loadTasks(); // List reload
            },
            child: Text('ဖျက်မည်'),
          ),
        ],
      ),
    );
  }

  void _addTask(String title, String? description, [String? category]) async {
    await _dbHelper.insertTask({
      'title': title,
      'description': description ?? '',
      'category': category ?? 'ပုဂ္ဂိုလ်',
      'is_completed': 0,
    });
    if (mounted) _loadTasks();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add_task, color: Colors.blue[600], size: 24),
              ),
              SizedBox(width: 12.w),
              Text('အလုပ်အသစ်', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                onChanged: (value) {
                  setDialogState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'ခေါင်းစဉ် *',
                  prefixIcon: Icon(Icons.title, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: descController,
                onChanged: (value) {
                  setDialogState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'ဖော်ပြချက် *',
                  prefixIcon: Icon(Icons.description, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('ပယ်ဖျက်'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty)
                    ? Colors.blue[500]!
                    : Colors.grey[300]!,
                foregroundColor:
                    (titleController.text.isNotEmpty &&
                        descController.text.isNotEmpty)
                    ? Colors.white
                    : Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  (titleController.text.isNotEmpty &&
                      descController.text.isNotEmpty)
                  ? () {
                      Navigator.pop(dialogContext);
                      _addTask(titleController.text, descController.text);
                    }
                  : null,
              child: Text('ထည့်မည်'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ကျွန်တော်တို့ရဲ့',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            Text(
              'အလုပ်များ',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['အားလုံး', 'ယနေ့', 'ပြီးစီး']
                    .map(
                      (filter) => Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[600],
                          backgroundColor: Colors.white,
                          elevation: _filter == filter ? 4 : 1,
                          onSelected: (_) => _filterTasks(filter),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(40.w),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.task_alt_outlined,
                            size: 64.sp,
                            color: Colors.blue[400],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'အလုပ်များ မရှိသေးပါ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            '+ ခလုတ်နှိပ်ပြီး သင့်ရဲ့ ပထမဆုံး အလုပ်ကို ထည့်ပါ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return Slidable(
                        key: ValueKey(task['id']),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteTask(task['id']),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'ဖျက်ရန်',
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onLongPress: () => _deleteTask(task['id']),
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: task['is_completed'] == 1
                                          ? Colors.green[50]!
                                          : Color.lerp(
                                              _getCategoryColor(
                                                task['category'],
                                              ),
                                              Colors.white,
                                              0.8,
                                            )!,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: task['is_completed'] == 1
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.green[500],
                                            size: 20.sp,
                                          )
                                        : Icon(
                                            Icons.label,
                                            color: _getCategoryColor(
                                              task['category'],
                                            ),
                                            size: 20.sp,
                                          ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['title'],
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                task['is_completed'] == 1
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: task['is_completed'] == 1
                                                ? Colors.grey[500]
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (task['description']?.isNotEmpty ==
                                            true) ...[
                                          SizedBox(height: 4.h),
                                          Text(
                                            task['description'],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: task['is_completed'] == 1,
                                    activeColor: Colors.blue[500],
                                    onChanged: (value) =>
                                        _toggleTask(task['id'], value ?? false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[500],
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('အလုပ်ထည့်', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 6,
        onPressed: _showAddTaskDialog,
      ),
    );
  }
}
