import 'package:flutter/material.dart';
import 'package:mobile/components/comment_preview.dart';
import 'package:mobile/models/comment.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/utils/styles.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key, required this.productID}) : super(key: key);
  final String productID;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  Future<Product>? _product;

  @override
  void initState() {
    super.initState();
    _product = _productService.getProduct(widget.productID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Product>(
          future: _product,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Image.network(
                              snapshot.data!.img!,
                              width: 190,
                              height: 230,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              snapshot.data!.name,
                              style: kHeadingTextStyle,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              snapshot.data!.publisher! +
                                  " - " +
                                  (snapshot.data!.author ?? "No author"),
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "\$ " + snapshot.data!.cost.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Stock: " + snapshot.data!.amount.toString(),
                              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                User? user = UserService.getCurrentUser();
                                bool exists = false;
                                for (int i = 0; i < user!.cart!.length; i++) {
                                  if (user.cart![i]["product_id"] == snapshot.data!.id) {
                                    exists = true;
                                    user.cart![i]["amount"] = (user.cart![i]["amount"] + 1);
                                  }
                                }
                                if (!exists) {
                                  user.cart!.add({"product_id": snapshot.data!.id, "amount": 1});
                                }
                                UserService.updateUser(user);
                              },
                              child: Text(
                                "Add to cart",
                                style: kButtonLightTextStyle,
                              ),
                              style:
                                  OutlinedButton.styleFrom(backgroundColor: AppColors.background),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: const [
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Comments",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            FutureBuilder<List<String>>(
                              future:
                                  _productService.getUsersByCommentList(snapshot.data!.comments!),
                              builder: (context, commentSnapshot) {
                                if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (commentSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (commentSnapshot.hasError) {
                                    return const Text('Error');
                                  } else if (commentSnapshot.hasData) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          commentSnapshot.data!.isNotEmpty ?
                                          Expanded(
                                            child: Column(
                                              children: List.generate(
                                                  snapshot.data!.comments!.length,
                                                  (index) => CommentPreview(
                                                      comment: Comment(
                                                          username: commentSnapshot.data![index],
                                                          commentContent: snapshot
                                                              .data!.comments![index]["comment"]))),
                                            ),
                                          ) : const Text("There are no comments yet."),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const Text('Empty data');
                                  }
                                } else {
                                  return Text('State: ${commentSnapshot.connectionState}');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        ),
      ),
    );
  }
}
