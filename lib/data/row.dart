import 'package:flutter/material.dart';
import 'package:sevis_lakay/models/category_Item.dart';
import 'package:sevis_lakay/models/row_category.dart';

List<RowCategories> rowCategories = [
  RowCategories(
    name: 'Restaurant',
    iconData: Icons.restaurant,
    categoryitems: [
      CategoryItem(
        name: 'Restaurant',
        image: ('assets/images/restoran.png'),
        adress: '123 Main St, Cityville',
        distance: '2.5 km',
        open: 'Open',
        review: '(200 reviews)',
        valeur: 4.5,
        num: '(509) 55 2459 49',
        site: 'restaurant.com',
      ),
      CategoryItem(
        name: 'Restaurant',
        image: ('assets/images/restoran.png'),
        adress: '123 Main St, Cityville',
        distance: '2.5 km',
        open: 'Open',
        review: '(200 reviews)',
        valeur: 4.5,
        num: '(509) 55 2459 49',
        site: 'restaurant.com',
      ),
    ],
  ),

  RowCategories(
    name: 'Bank',
    iconData: Icons.account_balance,
    categoryitems: [
      CategoryItem(
        name: 'Bank',
        image: ('assets/images/bank.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Close',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '58993 94595830',
        site: 'banklakay.com',
      ),
      CategoryItem(
        name: 'Bank',
        image: ('assets/images/bank.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Close',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '58993 94595830',
        site: 'banklakay.com',
      ),
    ],
  ),

  RowCategories(
    name: 'Eglise',
    iconData: Icons.church,
    categoryitems: [
      CategoryItem(
        name: 'Eglise',
        image: ('assets/images/eglise.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '39483 84728 283',
        site: 'eglis449.com',
      ),
      CategoryItem(
        name: 'Eglise',
        image: ('assets/images/eglise.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '39483 84728 283',
        site: 'eglis449.com',
      ),
    ],
  ),

  RowCategories(
    name: 'Hotel',
    iconData: Icons.hotel,
    categoryitems: [
      CategoryItem(
        name: 'Hotel',
        image: ('assets/images/hotel.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '3948 4938 384',
        site: 'hotel495.com',
      ),
      CategoryItem(
        name: 'Hotel',
        image: ('assets/images/hotel.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '3948 4938 384',
        site: 'hotel495.com',
      ),
    ],
  ),

  RowCategories(
    name: 'Bank',
    iconData: Icons.account_balance,
    categoryitems: [
      CategoryItem(
        name: 'Bank',
        image: ('assets/images/bank.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '2938 2948 2949',
        site: 'bankhaiti.com',
      ),
      CategoryItem(
        name: 'Bank',
        image: ('assets/images/bank.png'),
        adress: '456 Elm St, Townsville',
        distance: '1.2 km',
        open: 'Open',
        review: '(150 reviews)',
        valeur: 4.0,
        num: '2938 2948 2949',
        site: 'bankhaiti.com',
      ),
    ],
  ),
];
