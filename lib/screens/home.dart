import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  var data;
  Future<void>? future;
  final List<String> countries = [
    'United States',
  ];

  final List<String> genders = [
    'female',
    'male',
  ];

  // Initially selected country
  String? selectedCountry;
  String? selectedGender;
  bool isLoading = false;
  String sortId = 'desc';
  String sortName = 'desc';
  String sortAgeorder = 'desc';
  int skipvalue = 0;
  String? genderinitial;

  Future<void> getUserDetails() async {
    final response =
        await get(Uri.parse('https://dummyjson.com/users?limit=10'));
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchGenderDetails(String gender) async {
    final response = await get(Uri.parse(
        'https://dummyjson.com/users/filter?key=gender&value=$gender&limit=10'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load gender details');
    }
  }

  Future<void> sortFullName() async {
    if (sortName == 'desc') {
      sortName = 'asc';
    } else {
      sortName = 'desc';
    }
    final response = await get(Uri.parse(
        'https://dummyjson.com/users?sortBy=firstName&order=$sortName&limit=10'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
        isLoading = false;
      });
    } else {
      throw Exception('Failed to sort full name');
    }
  }

  Future<void> sortIdOrder() async {
    if (sortId == 'desc') {
      sortId = 'asc';
    } else {
      sortId = 'desc';
    }
    final response = await get(Uri.parse(
        'https://dummyjson.com/users?sortBy=id&order=$sortId&limit=10'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
        isLoading = false;
      });
    } else {
      throw Exception('Failed to sort id');
    }
  }

  Future<void> sortAge() async {
    if (sortAgeorder == 'desc') {
      sortAgeorder = 'asc';
    } else {
      sortAgeorder = 'desc';
    }
    final response = await get(Uri.parse(
        'https://dummyjson.com/users?sortBy=age&order=$sortAgeorder&limit=10'));

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
        isLoading = false;
      });
    } else {
      throw Exception('Failed to sort age');
    }
  }

  Future<void> nextPage() async {
    final response;
    if (selectedGender == null) {
      response = await get(
          Uri.parse('https://dummyjson.com/users?limit=10&skip=$skipvalue'));
    } else {
      response = await get(Uri.parse(
          'https://dummyjson.com/users/filter?key=gender&value=$selectedGender&limit=10&skip=$skipvalue'));
    }

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body.toString());
        isLoading = false;
      });
    } else {
      throw Exception('Failed to skip');
    }
  }

  @override
  void initState() {
    super.initState();
    future = getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text('Employees'),
            SizedBox(width: 700),
            Icon(Icons.filter_alt),
            SizedBox(width: 20),
            DropdownButton<String>(
              hint: Text('Country'),
              value: selectedCountry,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCountry = newValue!;
                });
              },
              items: countries.map<DropdownMenuItem<String>>((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
            ),
            SizedBox(width: 20),
            DropdownButton<String>(
              hint: Text('Gender'),
              value: selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue;
                  isLoading = true;
                  future = fetchGenderDetails(newValue!);
                });
              },
              items: genders.map<DropdownMenuItem<String>>((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (data == null || data['users'] == null) {
                  return Center(child: Text('No data available'));
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DataTable(
                            columns: [
                              DataColumn(
                                label: InkWell(
                                  onTap: () {
                                    // Sort full name
                                    setState(() {
                                      isLoading = true;
                                      future = sortIdOrder();
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text('Id'),
                                      SizedBox(
                                          width:
                                              4), // Space between icon and text
                                      Icon(
                                        // isSortedAscending
                                        // ? Icons.arrow_upward
                                        Icons.arrow_downward,
                                        size: 16,
                                      ), // Arrow icon indicating sort direction
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(label: Text('Image')),
                              DataColumn(
                                label: InkWell(
                                  onTap: () {
                                    // Sort full name
                                    setState(() {
                                      isLoading = true;
                                      future = sortFullName();
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text('Full Name'),
                                      SizedBox(
                                          width:
                                              4), // Space between icon and text
                                      Icon(
                                        // isSortedAscending
                                        // ? Icons.arrow_upward
                                        Icons.arrow_downward,
                                        size: 16,
                                      ), // Arrow icon indicating sort direction
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: InkWell(
                                  onTap: () {
                                    // Sort full name
                                    setState(() {
                                      isLoading = true;
                                      future = sortAge();
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text('Demography'),
                                      SizedBox(
                                          width:
                                              4), // Space between icon and text
                                      Icon(
                                        // isSortedAscending
                                        // ? Icons.arrow_upward
                                        Icons.arrow_downward,
                                        size: 16,
                                      ), // Arrow icon indicating sort direction
                                    ],
                                  ),
                                ),
                              ),
                              DataColumn(label: Text('Designation')),
                              DataColumn(label: Text('Address')),
                            ],
                            rows: List<DataRow>.generate(
                              data['users'].length,
                              (index) => DataRow(
                                cells: [
                                  DataCell(Text(
                                      data['users'][index]['id'].toString())),
                                  DataCell(Image.network(
                                      data['users'][index]['image'])),
                                  DataCell(Text(
                                      '${data['users'][index]['firstName']} ${data['users'][index]['maidenName']} ${data['users'][index]['lastName']}')),
                                  DataCell(Text(
                                    '${data['users'][index]['gender'] == 'male' ? 'M' : 'F'}/${data['users'][index]['age']}',
                                  )),
                                  DataCell(Text(data['users'][index]['company']
                                      ['title'])),
                                  DataCell(Text(
                                      '${data['users'][index]['address']['city']}, ${data['users'][index]['address']['country']}')),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  skipvalue = skipvalue - 10;
                                  setState(() {
                                    isLoading = true;
                                    future = nextPage();
                                  });
                                },
                                child: Text('Previous'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  skipvalue = skipvalue + 10;
                                  setState(() {
                                    isLoading = true;
                                    future = nextPage();
                                  });
                                },
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
