# My Vagrant

なんかいろいろ試してみたいとかそういう時にちゃちゃっと環境を作るためのものです。

# 使い方

いまんとこ、puppetマニフェストの実験台に使うためのあれこれのみ整備してます。

## puppetマニフェストを準備する

以下のように、my-vagrantと同じ階層に、puppetマニフェストが起かれているとしましょう。

```
my-vagrant/
          /switch_to
          /...
my-puppet/
         /...
```

このmy-puppetディレクトリを、Vagrantに認識させる必要があります。そこで、まずswitch_toスクリプトを実行して、あらかじめ決められた場所にシンボリックリンクを張りましょう。

```
$ ./switch_to ../my-puppet
```

すると、my-vagrantのひと階層上に、指定したディレクトリへのシンボリックリンクが、vagrant-puppetとして張られます。

```
vagrant-puppet/ -> ../my-puppet
```

このvagrant-puppetディレクトリが、Vagrant上で/etc/vagrant/sharedとしてマウントされます。

## Vagrantを起動する

いまのところCentOS6.3のみ用意しています。

```
$ cd centos6.3
$ vagrant up
```

vagrant upすると、CentOS6.3のboxを自動的に取得して、起動します。この時、最低限必要なものをpuppetマニフェストに従ってインストールします。以下のようなものがあります。

  * git
  * epel
  * puppet
  * puppet-server
  * redhat-lsb

## Puppetマニフェストを適用する

上記のようにしてVagrantを起動すると、puppetmasterdが適切設定された上で動いている状態になっているはずです。

  * manifestdir = $confdir/shared/manifests
  * modulepath  = $confdir/shared/modules:$vardir/modules
  * templatedir = $confdir/shared/templates

ここで、以下のようにしてpuppet agentを実行し、マニフェストを適用します。

```
$ sudo puppet agent --test --server vagrant.private
```

# トラブルシュート

## Puppetまわりでなんかおかしなことがあったら

お近くのpuppetマスターにおたずねください。

## /etc/puppet/shareがマウントされない

以下のようなメッセージがでて、マウントできないことがあるようです。

```
[default] Configuring and enabling network interfaces...
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

/sbin/ifup eth1 2> /dev/null
```

このissueをたよりにがんばってください。

  * https://github.com/mitchellh/vagrant/issues/997

