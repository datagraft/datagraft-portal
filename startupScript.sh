docker exec -i datagraft-db psql --user=postgres --dbname=datagraft-prod << EOF

INSERT INTO users VALUES (1, 'jenkins@datagraft.net', '\$2a\$10\$t5e06Ja9ge3JLpmOKUG6IOGH/Qsvdh.TWnSuQ9MdHlbWchVGj4rnW', null, null, null, 1, '2016-05-09 12:19:41.745909', '2016-05-09 12:19:41.745909', '10.0.2.2', '10.0.2.2', '2016-05-09 12:19:41.740838', '2016-05-09 12:19:41.747083', null, null, null, null, null, null, null, 'jenkins', 0, true);

INSERT INTO oauth_applications (id, name, uid, secret, redirect_uri, scopes, created_at, updated_at) VALUES (1, 'Grafterizer', '49ef5d705ed7c76f7529fe358bdc981e82ad681cae75a8c70061d7f98e47660b', '4f976fd05a042cf82cb8b48f18ee3faa130dfb4202029fd22606dc2db868b805', 'http://localhost:8082/oauth/callback', 'public', '2016-05-04 08:44:01.702687', '2016-05-04 08:44:01.702687');
EOF
